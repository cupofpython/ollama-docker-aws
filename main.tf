provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "id_ed25519.pub" # Replace with your key name
  public_key = file("~/.ssh/id_ed25519.pub") # Replace with your public key path
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker_instance" {
  ami                    = "ami-0d0f28110d16ee7d6"
  instance_type          = "c4.8xlarge"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable docker
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "Docker-EC2"
  }
}

output "instance_ip" {
  value = aws_instance.docker_instance.public_ip
}
