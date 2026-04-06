terraform {
  backend "s3" {
    bucket = "sachin-terraform-backend-2026"
    key = "noteapp-ec2/state.tfstate"
    region = "us-east-2"
    profile = "default"
  }
}