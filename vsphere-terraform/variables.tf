# User vars
variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
  sensitive = true
}

# General vars
variable "vsphere_server" {
  type = string
}

variable "datacenter_name" {
  type = string
}

variable "datastore_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "public_network_id" {
  type = string
}

variable "server_template" {
  type = string
}

variable "folder_name" {
  type = string
}

