
variable 'region' {
  type        = string
  description = 'The AWS region to deploy to'
}

variable 'availability_zones' {
  type        = list(string)
  description = 'The availability zones to deploy to'
}

variable 'ami_id' {
  type        = string
  description = 'The ID of the AMI to use for the EC2 instances'
}

variable 'key_name' {
  type        = string
  description = 'The name of the key pair to use for the EC2 instances'
}

variable 'database_username' {
  type        = string
  description = 'The username for the RDS database'
}

variable 'database_password' {
  type        = string
  description = 'The password for the RDS database'
}
