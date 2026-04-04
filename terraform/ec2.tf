# create ec2 instance 
resource "aws_instance" "first-instance" {
  ami                         = "ami-0f88e80871fd81e91"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-instance-profile.name
  subnet_id                   = aws_subnet.public_subet_a.id
  associate_public_ip_address = true
  #   user_data                   = file("install.sh")
  user_data_base64 = base64encode("${templatefile("${path.module}/data/install.sh", {
    REGION        = var.AWS_REGION
    ECR_REPO_NAME = var.ecr_repo_name
    EFS_ID        = aws_efs_file_system.mongodb-efs.id
    ACCOUNT_ID    = data.aws_caller_identity.current.account_id
  })}")

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  tags = {
    Name = "first-instance"
  }

  depends_on = [aws_iam_role.ec2-role, aws_efs_file_system.mongodb-efs]
}
