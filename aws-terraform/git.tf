#Create an elastic IP that the git host to stay the same
resource "aws_eip" "ipgit" {
instance = aws_instance.git_host.id
  tags = {
    Name = "gitEIP"
  }
}

resource "aws_security_group" "git" {
  name = "Git"
  description = "Allow SSH and RDP"
  vpc_id = "${aws_vpc.team_vpc.id}"
# Ingress rule to allow SSH
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # Allow only the BYUI network to SSH in
    # cidr_blocks = ["157.201.0.0/16"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ingress {
  #  description = "HTTPS"
  #  from_port = 443
  #  to_port = 443
  #  protocol = "tcp"
  #  # cidr_blocks = ["157.201.0.0/16"]
  #  cidr_blocks = ["0.0.0.0/0"]
  #
  #}
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Git"
  }
}

# Create an EC2 instance running Debian 12 (20250316-2053)
# N. Virginia (us-east-1)
resource "aws_instance" "git_host" {
  ami = "ami-0779caf41f9ba54f0"
  instance_type = "t3.small"
  subnet_id = "${aws_subnet.public_subnet.id}"
  key_name = aws_key_pair.server_key.key_name
  vpc_security_group_ids = [aws_security_group.git.id]
  associate_public_ip_address = "true"
  tags = {
    Name = "git_host"
  }
  user_data = <<EOF
#!/bin/bash 
sudo apt update
sudo apt -y install vim
EOF
}
