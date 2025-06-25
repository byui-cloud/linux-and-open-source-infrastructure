#!/bin/bash
# deletes the resources
# curl -O https://byui-cloud.github.io/linux-and-open-source-infrastructure/aws-terraform/deleteeverything.sh && chmod a+x deleteeverything.sh
# Specify the directory path

rm -f private_key.pem
rm -f private_key.key

# Replace the instance names in the array with the actual names of your instances
instance_names=("bastion_host")

for instance_name in "${instance_names[@]}"; do
    # Terminate instances with the specified name directly
    aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name" --query 'Reservations[].Instances[].InstanceId' --output text)

    echo "Termination request sent for instances with Name '$instance_name'."
done >/dev/null


# Remove 'Bastion' and 'Internal' security groups except the default

# Get the list of VPC IDs
vpc_ids=$(aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text)

# Check if VPC IDs are found
if [ -z "$vpc_ids" ]; then
  echo "Error: No VPCs found or unable to retrieve VPC IDs."
  exit 1
fi

# Loop through each VPC ID
for vpc_id in $vpc_ids; do
  echo "Processing VPC ID: $vpc_id"

  # Delete Security Group 'Bastion' if it exists
  bastion_group_id=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=Bastion" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
  if [ -n "$bastion_group_id" ]; then
    echo "Deleting Security Group 'Bastion' in VPC $vpc_id"
    aws ec2 delete-security-group --group-id "$bastion_group_id"
    echo "Security Group 'Bastion' deleted successfully."
  else
    echo "Security Group 'Bastion' not found in VPC $vpc_id"
  fi

  # Delete Security Group 'Internal' if it exists
  internal_group_id=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=Internal" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
  if [ -n "$internal_group_id" ]; then
    echo "Deleting Security Group 'Internal' in VPC $vpc_id"
    aws ec2 delete-security-group --group-id "$internal_group_id"
    echo "Security Group 'Internal' deleted successfully."
  else
    echo "Security Group 'Internal' not found in VPC $vpc_id"
  fi

  # Delete Security Group 'nat_security' if it exists
  nat_security_group_id=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=nat_security_group" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
  if [ -n "$nat_security_group_id" ]; then
    echo "Deleting Security Group 'nat_security' in VPC $vpc_id"
    aws ec2 delete-security-group --group-id "$nat_security_group_id"
    echo "Security Group 'nat_security' deleted successfully."
  else
    echo "Security Group 'nat_security' not found in VPC $vpc_id"
  fi

  # Delete Security Group 'rds_sg' if it exists
  rds_sg_id=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=rds_sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
  if [ -n "$rds_sg_id" ]; then
    echo "Deleting Security Group 'rds_sg' in VPC $vpc_id"
    aws ec2 delete-security-group --group-id "$rds_sg_id"
    echo "Security Group 'rds_sg' deleted successfully."
  else
    echo "Security Group 'rds_sg' not found in VPC $vpc_id"
  fi

    # Delete Security Group 'allow-ssh' if it exists
  allow-ssh_id=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=allow-ssh" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
  if [ -n "$allow-ssh_id" ]; then
    echo "Deleting Security Group 'allow-ssh' in VPC $vpc_id"
    aws ec2 delete-security-group --group-id "$allow-ssh_id"
    echo "Security Group 'allow-ssh' deleted successfully."
  else
    echo "Security Group 'allow-ssh' not found in VPC $vpc_id"
  fi
done



# Remove all network interfaces
aws ec2 describe-network-interfaces --query 'NetworkInterfaces[*].[NetworkInterfaceId]' --output text | xargs -I {} aws ec2 delete-network-interface --network-interface-id {}

# Release all static IPs
aws ec2 describe-addresses --query 'Addresses[*].[AllocationId]' --output text | xargs -I {} aws ec2 release-address --allocation-id {}

# Delete all key pairs
aws ec2 delete-key-pair --key-name "server"

# Delete the subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=team_vpc" --query "Subnets[*].SubnetId" --output text | xargs -n 1 aws ec2 delete-subnet --subnet-id

#Delete the internet gateways
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=team_vpc" --query "InternetGateways[*].InternetGatewayId" --output text | xargs -n 1 aws ec2 detach-internet-gateway --internet-gateway-id && aws ec2 delete-internet-gateway --internet-gateway-id

# Delete Route Tables:
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=team_vpc" --query "RouteTables[*].RouteTableId" --output text | xargs -n 1 aws ec2 delete-route-table --route-table-id

# Delete Security Groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=team_vpc" --query "SecurityGroups[*].GroupId" --output text | xargs -n 1 aws ec2 delete-security-group --group-id

# Delete network ACLS
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<Your-VPC-ID>" --query "NetworkAcls[*].NetworkAclId" --output text | xargs -n 1 aws ec2 delete-network-acl --network-acl-id

# Delete the VPC
aws ec2 delete-vpc --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=team_vpc" --query "Vpcs[0].VpcId" --output text)


rm -f terraform.tfstate
