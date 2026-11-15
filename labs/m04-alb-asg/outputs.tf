output "alb_dns_name" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "HTTP URL of the load balancer"
  value       = "http://${aws_lb.app.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}
