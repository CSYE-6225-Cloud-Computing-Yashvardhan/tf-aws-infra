resource "aws_autoscaling_group" "web_app_asg" {
  name                      = "web_app_asg"
  desired_capacity          = var.desired_capacity_asg
  max_size                  = var.max_size_asg
  min_size                  = var.min_size_asg
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  default_cooldown          = 60

  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "webapp-instance"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "web_app_asg_scale_up_policy" {
  name                   = "web_app_asg_scale_up_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scaling_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_app_asg_scale_up_alarm" {
  alarm_name          = "web_app_asg_scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scaling_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_scale_up_threshold
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.web_app_asg_scale_up_policy.arn]
}

resource "aws_autoscaling_policy" "web_app_asg_scale_down_policy" {
  name                   = "web_app_asg_scale_down_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scaling_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_app_asg_scale_down_alarm" {
  alarm_name          = "web_app_asg_scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scaling_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_scale_down_threshold
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.web_app_asg_scale_down_policy.arn]
}


