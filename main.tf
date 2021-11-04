required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 3.0"

  }
  docker = {
    source = "kreuzwerker/docker"
    version = "2.15.0"
  }
}
provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "/Users/tf_user/.aws/creds"
  profile                 = "customprofile"
}

resource "aws_security_group_rule" "foo" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.my_vpc.cidr_block]
  ipv6_cidr_blocks  = [aws_vpc.my_vpc.cidr_block]
  security_group_id = "sg-123456"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2"

  tags = {
    Name = "tf-example"
  }
}
resource "aws_ami_copy" "foo" {
  name              = "terraform1"
  description       = "A copy of ami‑0e605e9bcfac420c0"
  source_ami_id     = "ami-e605e9bcfac420c0"
  source_ami_region = "us-east-2"

  tags = {
    Name = "ami"
  }
}
resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami {
    aws_id = aws_ami_copy.foo.id
  instance_type = "t2.large"
 }


  boot_disk {
    initialize_params {
      boot-mode = "uefi"
    }
  }
  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
  metadata = {
    user-data = "${file("/home/user1/data/meta.txt")}"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "ubuntu" {
  name  = "foo"
  image = docker_image.ubuntu.latest
}

data "docker_registry_image" "ubuntu" {
  name = "ubuntu:precise"
}

resource "docker_image" "ubuntu" {
  name = data.docker_registry_image.ubuntu.name
}


