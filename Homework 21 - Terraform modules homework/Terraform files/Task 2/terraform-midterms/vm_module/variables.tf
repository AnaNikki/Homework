variable "base_name" {
  type        = string
  description = "task3"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "vms_subnet_id" {
  type    = string
  default = "10.0.1.0/24"
}

variable "my_public_ip" {
  type    = string
  default = "185.100.244.35"
}

variable "my_password" {
  type    = string
  default = "adminuser1234!"
}
