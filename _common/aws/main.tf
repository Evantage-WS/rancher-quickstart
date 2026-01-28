# Flow:

# - create destroy script
# - vpc
# - internet gateway
# - subnet
# - route table
# - route table association
# - security group
# - rancher manager instance with public ip
# - rancher manager
# - rancher downstream instance with public ip
# - suse security

# Create _destroy.sh script, after the creation of the resourcegroup
# All created files at create time will be destroyed, except the files created by terraform init
resource "null_resource" "create_destroy_script" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when = create
    working_dir = path.root
    command = <<EOT
    OUTPUT_FILE='_destroy.sh'
    echo '#!/usr/bin/env bash\n' > $${OUTPUT_FILE}
    echo './files/destroy_aws_resources.sh Environment "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"' >> $${OUTPUT_FILE}
    echo 'EXIT_CODE=$?' >> $${OUTPUT_FILE}
    echo 'if [ $EXIT_CODE -ne 0 ]; then' >> $${OUTPUT_FILE}
    echo '  echo "destroy aborted...... exit_code=$${EXIT_CODE} - exiting now"' >> $${OUTPUT_FILE}
    echo '  exit $${EXIT_CODE}' >> $${OUTPUT_FILE}
    echo 'fi' >> $${OUTPUT_FILE}
    echo 'echo "Remove local files"' >> $${OUTPUT_FILE}
    echo 'rm -rf terraform.tfstat*' >> $${OUTPUT_FILE}
    echo 'rm -rf '${local.config.kubeconfig_location}/k3s-${local.config.name_cloud_provider}-${local.config.kubernetes_cluster_name}-rancher.yaml'' >> $${OUTPUT_FILE}
    echo 'rm -rf '${local.config.kubeconfig_location}/k3s-${local.config.name_cloud_provider}-${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}.yaml'' >> $${OUTPUT_FILE}
    echo 'rm -rf ${local.output_directory_for_config_files}' >> $${OUTPUT_FILE}
    echo 'rm _destroy.sh' >> $${OUTPUT_FILE}
    chmod +x $${OUTPUT_FILE}
EOT
  }
}
resource "aws_key_pair" "environment" {
  key_name_prefix                       = "${local.config.aws_prefix}-public-key"
  public_key                            = file(var.ssh_public_key_file)
  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

resource "aws_vpc" "environment" {
  cidr_block                            = "10.0.0.0/16"
  enable_dns_hostnames                  = true
  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

resource "aws_internet_gateway" "environment" {
  vpc_id = aws_vpc.environment.id

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

resource "aws_subnet" "environment" {
  vpc_id                                = aws_vpc.environment.id

  cidr_block                            = "10.0.0.0/24"
  availability_zone                     = join("", [ var.aws_region, var.aws_zone])

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

resource "aws_route_table" "environment" {
  vpc_id                                = aws_vpc.environment.id

  route {
    cidr_block                          = "0.0.0.0/0"
    gateway_id                          = aws_internet_gateway.environment.id
  }

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

resource "aws_route_table_association" "environment" {
  subnet_id                             = aws_subnet.environment.id
  route_table_id                        = aws_route_table.environment.id
}

# Security group to allow SSH, HTTP(S) and K8s API traffic
resource "aws_security_group" "enviroment" {
  name                                  = "${local.config.kubernetes_cluster_name}"
  description                           = "${local.config.kubernetes_cluster_name}"
  vpc_id                                = aws_vpc.environment.id

  ingress {
    from_port                           = 22
    to_port                             = 22
    protocol                            = "tcp"
    cidr_blocks                         = ["0.0.0.0/0"]
  }

  ingress {
    from_port                           = 6443
    to_port                             = 6443
    protocol                            = "tcp"
    cidr_blocks                         = ["0.0.0.0/0"]
  }

  ingress {
    from_port                           = 80
    to_port                             = 80
    protocol                            = "tcp"
    cidr_blocks                         = ["0.0.0.0/0"]
  }

  ingress {
    from_port                           = 443
    to_port                             = 443
    protocol                            = "tcp"
    cidr_blocks                         = ["0.0.0.0/0"]
  }

  egress {
    from_port                           = "0"
    to_port                             = "0"
    protocol                            = "-1"
    cidr_blocks                         = ["0.0.0.0/0"]
  }

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"
  }
}

# AWS EC2 instance for creating a single node RKE cluster and installing the Rancher node
resource "aws_instance" "rancher_node" {
  depends_on = [
    aws_route_table_association.environment
  ]
  ami                                   = data.aws_ami.image.id
  instance_type                         = local.config.aws_instance_type_rancher

  key_name                              = aws_key_pair.environment.key_name
  vpc_security_group_ids                = [aws_security_group.enviroment.id]
  subnet_id                             = aws_subnet.environment.id
  associate_public_ip_address           = true

  root_block_device {
    volume_size                         = 40
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                              = "ssh"
      host                              = self.public_ip
      user                              = local.config.aws_node_username
      private_key                       = file(var.ssh_private_key_file)
    }
  }

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}-rancher-node"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"

  }
}

# Rancher resources
module "rancher" {
  source                                = "../suse_rancher"

  providers = {
    helm                                = helm
    rancher2.bootstrap                  = rancher2.bootstrap
    rancher2.admin                      = rancher2.admin
  }

  node_public_ip                        = aws_instance.rancher_node.public_ip
  node_internal_ip                      = aws_instance.rancher_node.private_ip
  downstream_node_public_ip             = aws_instance.downstream_node.public_ip
  node_username                         = local.config.aws_node_username
  ssh_private_key                       = file(var.ssh_private_key_file)

  kubernetes_cluster_name               = local.config.kubernetes_cluster_name
  downstream_kubernetes_cluster_name    = local.config.downstream_kubernetes_cluster_name
  rancher_kubernetes_version            = local.config.rancher_kubernetes_version
  downstream_kubernetes_cluster_version = local.config.downstream_kubernetes_cluster_version

  kubeconfig_location                   = local.config.kubeconfig_location

  cert_manager_version                  = local.config.cert_manager_version
  rancher_version                       = local.config.rancher_version
  rancher_helm_repository               = local.config.rancher_helm_repository
  rancher_server_dns                    = join(".", ["rancher", aws_instance.rancher_node.public_ip, "sslip.io"])
  admin_password                        = var.rancher_server_admin_password

  name_cloud_provider                   = local.config.name_cloud_provider
}


# AWS EC2 instance for creating a single node workload cluster
resource "aws_instance" "downstream_node" {
  depends_on = [
    aws_route_table_association.environment
  ]
  ami                                   = data.aws_ami.image.id
  instance_type                         = local.config.aws_instance_type_downstream

  key_name                              = aws_key_pair.environment.key_name
  vpc_security_group_ids                = [aws_security_group.enviroment.id]
  subnet_id                             = aws_subnet.environment.id
  associate_public_ip_address           = true

  root_block_device {
    volume_size = 40
  }

  user_data = templatefile(
    "${path.module}/files/userdata_downstream_node.template",
    {
      register_command                  = module.rancher.custom_cluster_command
    }
  )

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                              = "ssh"
      host                              = self.public_ip
      user                              = local.config.aws_node_username
      private_key                       = file(var.ssh_private_key_file)
    }
  }

  tags = {
    Name                                = "${local.config.kubernetes_cluster_name}-downstream-node"
    Creator                             = local.config.aws_creator_tag
    Environment                         = "${local.config.aws_creator_tag} - ${local.config.kubernetes_cluster_name}"

  }
}

# Install suse_security
module "suse_security" {
  count = local.config.install_suse_security ? 1 : 0
  depends_on = [
    aws_instance.downstream_node
  ]
  source                                = "../suse_security"

  providers = {
    helm                                = helm
  }
  suse_security_version                 = local.config.suse_security_version
  rancher_url                           = module.rancher.rancher_url
  kubernetes_cluster_name               = local.config.kubernetes_cluster_name
  suse_security_admin_password          = var.suse_security_admin_password
  suse_security_server_dns              = join(".", ["suse_security", aws_instance.rancher_node.public_ip, "sslip.io"])
  ssh_username                          = local.config.aws_node_username
  ssh_private_key                       = file(var.ssh_private_key_file)
  rancher_node_public_ip                = aws_instance.rancher_node.public_ip
}