# Flow:

# - create destroy script
# - resource group
# - virtual network
# - virtual subnet
# - rancher manager vm with virtual network interface and virtual ip
# - rancher manager
# - rancher downstream vm with virtual network interface and virtual ip
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
    echo 'az group delete --resource-group ${azurerm_resource_group.environment.name}' >> $${OUTPUT_FILE}
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

# Resource group containing all resources for this environment
resource "azurerm_resource_group" "environment" {
  name                                    = "${local.config.azure_prefix_for_resourcegroup}-${local.config.kubernetes_cluster_name}-rg"
  location                                = var.azure_location
  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

# Azure virtual network space
resource "azurerm_virtual_network" "environment" {
  name                                    = "${local.config.kubernetes_cluster_name}-virtual-network"
  address_space                           = ["10.0.0.0/16"]
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name
  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

# Azure internal subnet
resource "azurerm_subnet" "environment" {
  name                                    = "${local.config.kubernetes_cluster_name}-virtual-subnet"
  resource_group_name                     = azurerm_resource_group.environment.name
  virtual_network_name                    = azurerm_virtual_network.environment.name
  address_prefixes                        = ["10.0.0.0/16"]
}

# Public IP of Rancher node
resource "azurerm_public_ip" "rancher_node_public_ip" {
  name                                    = "${local.config.kubernetes_cluster_name}-rancher-node-interface-public-ip"
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name
  allocation_method                       = "Static"

  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

# Azure network interface
resource "azurerm_network_interface" "rancher_node_network_interface" {
  name                                    = "${local.config.kubernetes_cluster_name}-rancher-node-interface"
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name

  ip_configuration {
    name                                  = "rancher_node_ip_config"
    subnet_id                             = azurerm_subnet.environment.id
    private_ip_address_allocation         = "Dynamic"
    public_ip_address_id                  = azurerm_public_ip.rancher_node_public_ip.id
  }

  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

resource "azurerm_network_security_group" "environment" {
  name                = "${local.config.kubernetes_cluster_name}-network-security-group"
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name

  security_rule {
    name                                  = "ssh"
    priority                              = 100
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "22"
    source_address_prefix                 = "*"
    destination_address_prefix            = "*"
  }
  security_rule {
    name                                  = "k8s"
    priority                              = 101
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "6443"
    source_address_prefix                 = "*"
    destination_address_prefix            = "*"
  }
  security_rule {
    name                                  = "http"
    priority                              = 102
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "80"
    source_address_prefix                 = "*"
    destination_address_prefix            = "*"
  }
  security_rule {
    name                                  = "https"
    priority                              = 103
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "443"
    source_address_prefix                 = "*"
    destination_address_prefix            = "*"
  }
  security_rule {
    name                                  = "Egress"
    priority                              = 104
    direction                             = "Outbound"
    access                                = "Allow"
    protocol                              = "*"
    source_port_range                     = "*"
    destination_port_range                = "*"
    source_address_prefix                 = "*"
    destination_address_prefix            = "*"
  }

  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

resource "azurerm_network_interface_security_group_association" "downstream_node" {
  network_interface_id      = azurerm_network_interface.rancher_node_network_interface.id
  network_security_group_id = azurerm_network_security_group.environment.id
}

# Azure linux virtual machine for creating a single node K3s cluster and installing the Rancher Server/Neuvector
resource "azurerm_linux_virtual_machine" "rancher_node" {
  name                                    = "${local.config.kubernetes_cluster_name}-rancher-node"
  computer_name                           = "rancher-server" // ensure computer_name meets 15 character limit
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name
  network_interface_ids                   = [azurerm_network_interface.rancher_node_network_interface.id]
  size                                    = local.config.azure_instance_type_rancher
  admin_username                          = local.config.azure_node_username

  # az vm image list --publisher SUSE
  source_image_reference {
    publisher                             = "SUSE"
    offer                                 = "sles-15-sp7"
    sku                                   = "gen2"
    version                               = "latest"
  }

  admin_ssh_key {
    username                              = local.config.azure_node_username
    public_key                            = file(var.ssh_public_key_file)
  }

  os_disk {
    caching                               = "ReadWrite"
    storage_account_type                  = "Premium_LRS"
  }

  tags = {
    Creator                               = local.config.azure_creator_tag
  }

  provisioner "remote-exec" {
    inline                                = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                                = "ssh"
      host                                = self.public_ip_address
      user                                = local.config.azure_node_username
      private_key                         = file(var.ssh_private_key_file)
      timeout                             = "10m"
    }

  }
}

# Rancher resources
module "rancher" {
  source                                  = "../suse_rancher"

  providers = {
    helm                                  = helm
    rancher2.bootstrap                    = rancher2.bootstrap
    rancher2.admin                        = rancher2.admin
  }

  node_public_ip                          = azurerm_linux_virtual_machine.rancher_node.public_ip_address
  node_internal_ip                        = azurerm_linux_virtual_machine.rancher_node.private_ip_address
  node_username                           = local.config.azure_node_username
  downstream_node_public_ip               = azurerm_linux_virtual_machine.downstream_node.public_ip_address
  ssh_private_key                         = file(var.ssh_private_key_file)
  rancher_kubernetes_version              = local.config.rancher_kubernetes_version

  cert_manager_version                    = local.config.cert_manager_version
  rancher_version                         = local.config.rancher_version
  rancher_helm_repository                 = local.config.rancher_helm_repository

  rancher_server_dns                      = join(".", ["rancher", azurerm_linux_virtual_machine.rancher_node.public_ip_address, "sslip.io"])

  admin_password                          = var.rancher_server_admin_password

  kubernetes_cluster_name                 = local.config.kubernetes_cluster_name
  downstream_kubernetes_cluster_version   = local.config.downstream_kubernetes_cluster_version
  downstream_kubernetes_cluster_name      = local.config.downstream_kubernetes_cluster_name
  kubeconfig_location                     = local.config.kubeconfig_location
  name_cloud_provider                     = local.config.name_cloud_provider
}

# Public IP of downstream node
resource "azurerm_public_ip" "downstream_node_public_ip" {
  name                                    = "${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}-node-interface-public-ip"
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name
  allocation_method                       = "Static"

  tags = {
    Creator = local.config.azure_creator_tag
  }
}

# Azure network interface for downstream resources
resource "azurerm_network_interface" "downstream_node_network_interface" {
  name                                    = "${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}-node-interface"
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name

  ip_configuration {
    name                                  = "downstream_node_ip_config"
    subnet_id                             = azurerm_subnet.environment.id
    private_ip_address_allocation         = "Dynamic"
    public_ip_address_id                  = azurerm_public_ip.downstream_node_public_ip.id
  }

  tags = {
    Creator                               = local.config.azure_creator_tag
  }
}

resource "azurerm_network_interface_security_group_association" "rancher_node" {
  network_interface_id      = azurerm_network_interface.downstream_node_network_interface.id
  network_security_group_id = azurerm_network_security_group.environment.id
}


# Azure linux virtual machine for creating a single downstream node K3s cluster
resource "azurerm_linux_virtual_machine" "downstream_node" {
  name                                    = "${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}-node"
  computer_name                           = "downstream" // ensure computer_name meets 15 character limit
  location                                = azurerm_resource_group.environment.location
  resource_group_name                     = azurerm_resource_group.environment.name
  network_interface_ids                   = [azurerm_network_interface.downstream_node_network_interface.id]
  size                                    = local.config.azure_instance_type_downstream
  admin_username                          = local.config.azure_node_username


  custom_data = base64encode(
    templatefile(
      "${path.module}/files/userdata_downstream_node.template",
      {
        register_command                  = module.rancher.custom_cluster_command
      }
    )
  )

  source_image_reference {
    publisher                             = "SUSE"
    offer                                 = "sles-15-sp6"
    sku                                   = "gen2"
    version                               = "latest"
  }

  admin_ssh_key {
    username                              = local.config.azure_node_username
    public_key                            = file(var.ssh_public_key_file)
  }

  os_disk {
    caching                               = "ReadWrite"
    storage_account_type                  = "Premium_LRS"
  }

  tags = {
    Creator                               = local.config.azure_creator_tag
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                               = "ssh"
      host                               = self.public_ip_address
      user                               = local.config.azure_node_username
      private_key                        = file(var.ssh_private_key_file)
    }
  }
}

# Install Neuvector
module "suse_security" {
  count                                 = local.config.install_suse_security ? 1 : 0

  source                                = "../suse_security"
  depends_on                            = [azurerm_linux_virtual_machine.downstream_node]

  providers = {
    helm                                = helm
  }
  suse_security_version                 = local.config.suse_security_version
  rancher_url                           = module.rancher.rancher_url
  kubernetes_cluster_name               = local.config.kubernetes_cluster_name
  suse_security_admin_password          = var.suse_security_admin_password
  suse_security_server_dns              = join(".", ["suse_security", azurerm_linux_virtual_machine.rancher_node.public_ip_address, "sslip.io"])
  ssh_username                          = local.config.azure_node_username
  ssh_private_key                       = file(var.ssh_private_key_file)
  rancher_node_public_ip                = azurerm_linux_virtual_machine.rancher_node.public_ip_address
}
