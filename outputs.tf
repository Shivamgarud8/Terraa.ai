
output 'alb_dns_name' {
  value       = aws_alb.this.dns_name
  description = 'The DNS name of the Application Load Balancer'
}

output 'rds_endpoint' {
  value       = aws_db_instance.this.endpoint
  description = 'The endpoint of the RDS database'
}
