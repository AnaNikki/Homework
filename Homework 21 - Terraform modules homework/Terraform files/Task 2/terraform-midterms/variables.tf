variable "my_name" {
  type        = string
  description = "First name of the student"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The location where all resources will be placed."
}

variable "my_public_ip" {
  type = string
}

variable "my_password" {
  type = string
}
