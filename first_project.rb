# First define the environment which is available with the variable `env`
# This is where project invariants are stored, e.g. subnets, vpc ...
environment("staging") {
  account_id  "1"
  subnet      "1"
  vpc_id      "1"
}

# Create the first_project to be in the `staging` environment
project = project('org', 'first_project') {
  environments 'staging'
}

# Define the security group for the ELB to allow HTTP
elb_sg = project.resource("aws_security_group", "allow_http") {
  name         "allow_http"
  description  "Allow All HTTP"
  vpc_id       env.vpc_id
  ingress {
      from_port    80
      to_port      80
      protocol     "tcp"
      cidr_blocks  ["0.0.0.0/0"]
  }
  tags {
    Name "allow_http"
  }
}

# Define the security group for EC2 to allow ingress from the ELB
ec2_sg = project.resource("aws_security_group", "allow_elb") {
  name         "allow_elb"
  description  "Allow ELB to 80"
  vpc_id       env.vpc_id
  ingress {
      from_port    8000
      to_port      8000
      protocol     "tcp"
      security_groups  [elb_sg]
  }
  tags {
    Name "allow_elb"
  }
}

# cloud_config to run webserver
user_data = %{
#cloud-config
runcmd:
  - docker run -d --name nginx -p 8000:80 nginx
}

# Create an EC2 instance to run nginx server
instance = project.resource("aws_instance", "web") {
  ami           "ami-1c94e10b" # COREOS AMI
  instance_type "t1.micro"
  subnet_id     env.subnet
  user_data     user_data
  tags {
    Name "ec2_instance"
  }
}

# Create the ELB connected to the instance
project.resource("aws_elb", "main-web-app") {
  name             "main-app-elb"
  security_groups  [elb_sg]
  subnets          [env.subnet]
  instances        [instance]
  listener {
    instance_port     8000
    instance_protocol "http"
    lb_port           80
    lb_protocol       "http"
  }
}
