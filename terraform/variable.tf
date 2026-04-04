
variable "AWS_REGION" {
  description = "AWS Region"
  type    = string
  # default = "us-east-1"
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  # default = "dev_ecr_repo"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

