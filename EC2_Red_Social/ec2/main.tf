resource "aws_instance" "instance_linux" {
  ami             = var.ec2_ami_linux
  instance_type   = var.instance_type
  security_groups = [var.security_group_name]
  key_name        = var.ec2_keyname
  tags = {
    Name     = var.ec2_tag_name
    Ambiente = var.ec2_tag_ambiente
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo apt update && sudo apt upgrade -y && \
  mkdir app && \
  sudo apt install git -y && \
  cd app/ && git clone https://github.com/AGuekdjian/Red-Social.git && cd .. && \
  git clone https://github.com/AGuekdjian/Scripts.git && \
  mv ./Scripts/installDocker.sh . && \
  rm -rf ./Scripts && \
  ./installDocker.sh && \
  cd app/Red-Social && ./Docker.sh && \
  sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8000
  EOF
}

resource "aws_security_group" "security_group_terraform" {
  name = var.security_group_name
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web Server"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow All"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
