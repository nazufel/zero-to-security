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
