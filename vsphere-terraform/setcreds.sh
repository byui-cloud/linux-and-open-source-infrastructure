#!/bin/bash
# Script to cache vsphere creds in environment for terraform
# Must run with source in order to export to current session
# Usage: source setcreds.sh

# prompt for username and export to environment
read -p "Enter your provider username: " my_user
export TF_VAR_vsphere_user="$my_user"

# prompt for password and export to environment
read -sp "Enter your provider password: " my_pass
export TF_VAR_vsphere_password="$my_pass"

echo
echo "Creds cached in environment.  Close shell to clear cache."
