# Use latest SLES 15
data "aws_ami" "image" {
  most_recent = true
  owners      = ["679593333241"] # openSUSE

  filter {
    name   = "name"
    values = ["openSUSE-Leap-15-6*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

