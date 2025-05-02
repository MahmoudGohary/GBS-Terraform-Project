resource "aws_launch_template" "app" {
  name_prefix   = "app-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.public_sg]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd php git php-mysqlnd unzip awscli -y
    git clone https://github.com/sharara99/My-To-Do-List.git /var/www/html
    systemctl start httpd
    systemctl enable httpd
    sed -i 's/REPLACE_ME/${var.rds_endpoint}/' /var/www/html/db.php
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  name                = "ASG"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [var.alb_target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG_Instance"
    propagate_at_launch = true
  }
}

data "aws_instances" "asg_instances" {
  depends_on = [aws_autoscaling_group.asg]

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  filter {
    name   = "tag:Name"
    values = ["ASG_Instance"]
  }
}
