provider "aws" {
  region = "eu-west-1"
}

variable "cidr_blocks" { type = "list" }
variable "region" {}
variable "public_key_path" {}
variable "private_key_path" {}
variable "remote_user" {}
variable "dokku_version" {}
variable "dokku_app" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu*16.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "dokku_sg" {
  name = "dokku_sg"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${var.cidr_blocks}"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "${var.cidr_blocks}"
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = "${var.cidr_blocks}"
  }
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = "${var.cidr_blocks}"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dokku_key" {
  key_name   = "dokku_key"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "dokku" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"

  key_name        = "dokku_key"

  security_groups = ["dokku_sg"]

  tags {
    App = "Dokku"
  }

  provisioner "local-exec" {
    command = "echo ssh -i ${var.private_key_path} ${aws_instance.dokku.public_ip} -l ${var.remote_user} > ssh_connect.txt"
  }
  user_data = <<-EOF
              #!/bin/bash
              wget https://raw.githubusercontent.com/dokku/dokku/${var.dokku_version}/bootstrap.sh
              DOKKU_TAG=${var.dokku_version} bash bootstrap.sh
              dokku ssh-keys:add key01 /home/${var.remote_user}/.ssh/authorized_keys &> /var/log/dokku_config.log
              dokku apps:create ${var.dokku_app} &>> /var/log/dokku_config.log
              EOF
}

output "public_dns" {
  value = "${aws_instance.dokku.public_dns}"
}
