variable "region" {
  description = "The one AWS region everything in this course goes in"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Prefix for every resource name"
  type        = string
  default     = "notes"
}

variable "my_ip" {
  description = "Your public IP address, for SSH. Find it with: curl -s https://checkip.amazonaws.com"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Public key for the EC2 instance"
  type        = string
  default     = "~/.ssh/aws_lab.pub"
}

variable "admin_token_param" {
  description = "Name of the SSM parameter holding the admin token. Created by hand, never by OpenTofu."
  type        = string
  default     = "/notes/admin-token"
}
