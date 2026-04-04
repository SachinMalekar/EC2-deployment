# launch template 
resource "aws_launch_template" "dev-lt" {
  name                                 = "dev-lt"
  disable_api_stop                     = true
  disable_api_termination              = true
  ebs_optimized                        = true
  image_id                             = "ami-0f88e80871fd81e91"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  user_data = base64encode("${templatefile("${path.module}/data/install.sh", {
    REGION        = var.AWS_REGION
    ECR_REPO_NAME = var.ecr_repo_name
    EFS_ID        = aws_efs_file_system.mongodb-efs.id
    ACCOUNT_ID    = data.aws_caller_identity.current.account_id
  })}")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      delete_on_termination = "true"
      volume_size           = 8
      volume_type           = "gp2"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile.name
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2-sg.id]
    delete_on_termination       = "true"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
  depends_on = [aws_efs_file_system.mongodb-efs]
}

# placement strategy 
resource "aws_placement_group" "dev-placemet-group" {
  name     = "dev-placemet-group"
  strategy = "spread"
}

# auto scaling group 
resource "aws_autoscaling_group" "dev-asg" {
  name                      = "dev-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  placement_group           = aws_placement_group.dev-placemet-group.id
  vpc_zone_identifier       = [aws_subnet.private_subet_a.id, aws_subnet.private_subet_b.id]
  target_group_arns         = [aws_lb_target_group.dev-tg.arn]

  launch_template {
    id      = aws_launch_template.dev-lt.id
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  depends_on = [aws_lb.dev-alb]

}

# scale-up-policy
resource "aws_autoscaling_policy" "scale-up-policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.dev-asg.name
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-up-alaram" {
  alarm_name          = "scale-up-alaram"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 40
  alarm_description   = "This metric monitors ec2 cpu utilization"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.dev-asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale-up-policy.arn]
}

# scale-down-policy
resource "aws_autoscaling_policy" "scale-down-policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.dev-asg.name
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-down-alaram" {
  alarm_name          = "scale-down-alaram"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "This metric monitors ec2 cpu utilization"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.dev-asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale-down-policy.arn]
}
