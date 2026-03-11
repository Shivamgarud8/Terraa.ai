
# Configure the AWS Provider
provider 'aws' {
  region = 'us-west-2' # TODO: Add your region here (e.g., us-west-2)
}

# Create a VPC
resource 'aws_vpc' 'this' {
  cidr_block = '10.0.0.0/16'
  tags = {
    Name = '3-tier-web-architecture-vpc'
  }
}

# Create public subnets
resource 'aws_subnet' 'public' {
  count = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = '10.0.${count.index}.0/24'
  availability_zone = 'us-west-2${count.index}' # TODO: Add your availability zones here (e.g., us-west-2a)
  map_public_ip_on_launch = true
  tags = {
    Name = '3-tier-web-architecture-public-subnet-${count.index}'
  }
}

# Create private subnets
resource 'aws_subnet' 'private' {
  count = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = '10.0.${count.index + 2}.0/24'
  availability_zone = 'us-west-2${count.index}' # TODO: Add your availability zones here (e.g., us-west-2a)
  tags = {
    Name = '3-tier-web-architecture-private-subnet-${count.index}'
  }
}

# Create an Application Load Balancer
resource 'aws_alb' 'this' {
  name            = '3-tier-web-architecture-alb'
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb.id]
}

# Create a security group for the Application Load Balancer
resource 'aws_security_group' 'alb' {
  name        = '3-tier-web-architecture-alb-sg'
  description = 'Security group for the Application Load Balancer'
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = 'tcp'
    cidr_blocks = ['0.0.0.0/0']
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = '-1'
    cidr_blocks = ['0.0.0.0/0']
  }
}

# Create a security group for the EC2 instances
resource 'aws_security_group' 'ec2' {
  name        = '3-tier-web-architecture-ec2-sg'
  description = 'Security group for the EC2 instances'
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = 'tcp'
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = '-1'
    cidr_blocks = ['0.0.0.0/0']
  }
}

# Create an Auto Scaling Group for the EC2 instances
resource 'aws_autoscaling_group' 'this' {
  name                = '3-tier-web-architecture-asg'
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = aws_subnet.private.*.id
  launch_template {
    id      = aws_launch_template.this.id
    version = '$Latest'
  }
}

# Create a launch template for the EC2 instances
resource 'aws_launch_template' 'this' {
  name          = '3-tier-web-architecture-launch-template'
  image_id      = 'ami-0c94855ba95c71c99' # TODO: Add your AMI ID here (e.g., ami-0c94855ba95c71c99)
  instance_type = 't2.micro'
  key_name               = 'your-key' # TODO: Add your key name here (e.g., your-key)
  security_group_names    = [aws_security_group.ec2.name]
  user_data = filebase64('user-data.sh')
}

# Create a Multi-AZ RDS MySQL database
resource 'aws_db_instance' 'this' {
  identifier           = '3-tier-web-architecture-rds'
  engine               = 'mysql'
  engine_version       = '8.0.28'
  instance_class       = 'db.t2.micro'
  allocated_storage    = 20
  storage_type         = 'gp2'
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.this.name
  username             = 'your-username' # TODO: Add your database username here (e.g., your-username)
  password             = 'your-password' # TODO: Add your database password here (e.g., your-password)
  parameter_group_name = 'default.mysql8.0'
  publicly_accessible  = false
  skip_final_snapshot  = true
}

# Create a security group for the RDS database
resource 'aws_security_group' 'rds' {
  name        = '3-tier-web-architecture-rds-sg'
  description = 'Security group for the RDS database'
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = 'tcp'
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = '-1'
    cidr_blocks = ['0.0.0.0/0']
  }
}

# Create a DB subnet group for the RDS database
resource 'aws_db_subnet_group' 'this' {
  name       = '3-tier-web-architecture-rds-subnet-group'
  subnet_ids = aws_subnet.private.*.id
}
