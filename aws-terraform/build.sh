#!/bin/bash
# Installs terraform, creates a folder, and deploys an EC2 AWS Linux Mate server, juice shop on an internal ip, and deploys it
# Give execute permissions to this file and run it:
#  curl -O https://byui-cloud.github.io/cyber-201-materials/aws-terraform/build201.sh && chmod a+x build201.sh && ./build201.sh
# git clone https://github.com/tfutils/tfenv.git ~/.tfenv
# mkdir ~/bin
# ln -s ~/.tfenv/bin/* ~/bin/
# tfenv install
# tfenv use
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

git clone https://github.com/byui-cloud/linux-and-open-source-infrastructure.git

cd linux-and-open-source-infrastructure/aws-terraform
terraform init
terraform apply -auto-approve

echo "run ./connect.sh to connect."
