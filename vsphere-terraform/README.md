# cyber-201-vsphere-terraform

Terraform configuration for managing the Linux and Open Source Society Infrastructure on vSphere

## Useful links:

* Terraform vSphere Provider: https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs

## Setup

1. Install terraform
2. `terraform init` (if you haven't already)

## Public IP addresses and hostnames:

The domain names are: 
* `linux.cse.byui.edu` (157.201.19.95)
* `open-source.cse.byui.edu` (157.201.19.94)
* `los-git.cse.byui.edu` (157.201.19.93)
* `los-matrix.cse.byui.edu` (157.201.19.92)

These are all on the I-CIT-PUBLIC-19-K8S network (dvportgroup-2552).  This subnet was created for student projects and that is why we are here.

## Credentials

The following credentials are used on the system:

* vSphere - BYUI Creds (must be connected to VPN)
* Debian Templates
   * Sean Crosby has an account

## Template Details

### Debian-12.11.0-Net2

Based on the debian-12.11.0 netinstall ISO.  After installing the ISO, the following additions were made:
1. Configure a static IP (the public IP) in `/etc/network/interfaces`.  Note that this IP address will have to be manually updated since we didn't get it working with terraform (due to a vmware tools limitation?)
2. Setup the sources.list for apt
3. Install the following packages with apt: vim, open-vm-tools, net-tools
4. Configure resolve.conf (for 8.8.8.8)
5. Install Crowdstrike:
```
# see Carl's web server for instructions: http://157.201.16.2/falcon/
wget http://157.201.16.2/falcon/falcon-sensor_6.50.0-14712_amd64.deb
wget http://157.201.16.2/falcon/cid.txt
dpkg -i falcon-sensor_6.50.0-14712_amd64.deb
# fix dependency issues if needed.  May need to install libnl-3-200
/opt/CrowdStrike/falconctl -s --cid=`cat cid.txt`
systemctl start falcon-sensor
```
6. Install openssh-server: `apt install openssh-server`
7. Install and configure the firewall:
```
sudo apt install ufw
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
```

## TODO:
1. Find gateway on 157.201.16 network
2. Ensure the Falcon Sensor is working properly
