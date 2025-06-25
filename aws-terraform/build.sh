#!/bin/bash
# Installs terraform, clones a repository with terraform configs, and builds the infrastructure
# Give execute permissions to this file and run it:
#
# Usage from AWS Cloudshell: 
#   curl -O https://raw.githubusercontent.com/byui-cloud/linux-and-open-source-infrastructure/refs/heads/main/aws-terraform/build.sh && chmod a+x build.sh && ./build.sh

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

git clone https://github.com/byui-cloud/linux-and-open-source-infrastructure.git

cd linux-and-open-source-infrastructure/aws-terraform
terraform init
terraform apply -auto-approve

echo "run ./connect.sh to connect."
