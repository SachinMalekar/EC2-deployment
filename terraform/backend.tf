terraform {
  backend "s3" {
    bucket = "jayambar-terraform-backend"
    key = "noteapp-ec2/state.tfstate"
    region = "us-east-1"
    profile = "default"
  }
}