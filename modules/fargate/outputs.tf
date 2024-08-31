output "application_url" {
  value = aws_lb.app_load_balancer.dns_name
}