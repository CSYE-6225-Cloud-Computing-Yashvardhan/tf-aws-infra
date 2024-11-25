variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "vpc_suffix" {
  description = "A unique suffix to avoid naming conflicts"
  type        = string
}

variable "dest_cidr_block" {
  description = "Destination cidr block in route"
  type        = string
}

variable "vpc_tag_name" {
  description = "VPC tag name"
  type        = string
}

variable "int_gateway_name" {
  description = "Internet gateway tag name"
  type        = string
}

variable "pub-route-tbl" {
  description = "Public Route Table"
  type        = string
}

variable "pri_route_tbl" {
  description = "Private Route Table"
  type        = string
}

variable "ami_id" {
  description = "Custom AMI id"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "assoc_public_ip" {
  description = "Flag to associate public IP address"
  type        = bool
}

variable "aws_configured_key_name" {
  description = "SSH configured key name"
  type        = string
}

variable "disable_api_term" {
  description = "Flag to disable API termination"
  type        = bool
}

variable "vol_size" {
  description = "EC2 Volume size"
  type        = number
}

variable "vol_type" {
  description = "EC2 Volume type"
  type        = string
}

variable "delete_on_term" {
  description = "Flag to delete EC2 on termination"
  type        = bool
}

variable "protocol" {
  description = "Protocal name"
  type        = string
}

variable "outbound_protocol" {
  description = "Outbound Protocal name"
  type        = string
}

variable "ssh_port" {
  description = "Port number for SSH traffic"
  type        = number
}

variable "http_port" {
  description = "Port number for HTTP traffic"
  type        = number
}

variable "https_port" {
  description = "Port number for HTTPS traffic"
  type        = number
}

variable "custom_port" {
  description = "Port number for HTTPS traffic"
  type        = number
}

variable "outbound_port" {
  description = "Port number for Outbound traffic"
  type        = number
}

variable "ssh_cidr" {
  description = "Cidr block for SSH traffic"
  type        = list(string)
}

variable "http_cidr" {
  description = "Cidr block for HTTP traffic"
  type        = list(string)
}

variable "https_cidr" {
  description = "Cidr block for HTTPS traffic"
  type        = list(string)
}

variable "custom_cidr" {
  description = "Cidr block for Custom traffic"
  type        = list(string)
}

variable "outbound_cidr" {
  description = "Cidr block for Outbound traffic"
  type        = list(string)
}

variable "db_engine" {
  description = "DB engine"
  type        = string
}

variable "db_engine_ver" {
  description = "DB engine version"
  type        = string
}

variable "db_instance_class" {
  description = "DB instance type"
  type        = string
}

variable "db_storage" {
  description = "DB storage space"
  type        = number
}

variable "db_identifier" {
  description = "DB Identifier"
  type        = string
}

variable "db_name" {
  description = "DB name"
  type        = string
}

variable "db_user" {
  description = "DB username"
  type        = string
}

variable "db_pass" {
  description = "DB password"
  type        = string
}

variable "db_multi_az" {
  description = "DB multi az availability"
  type        = bool
}

variable "db_pub_access" {
  description = "DB public access"
  type        = bool
}

variable "db_skip_fi_snap" {
  description = "DB skip final snaphot"
  type        = bool
}

variable "db_para_family" {
  description = "DB parameter family"
  type        = string
}

variable "db_port" {
  description = "DB ports"
  type        = number
}

variable "domain_name" {
  description = "Domain Name (dev/demo) account"
  type        = string
}

variable "storage_class" {
  description = "storage class type for S3"
  type        = string
}

variable "encrypt_algo" {
  description = "Encryption algorithm for S3"
  type        = string
}

variable "desired_capacity_asg" {
  description = "Desired Capacity for Auto Scaling Group"
  type        = number
}

variable "max_size_asg" {
  description = "Max Capacity for Auto Scaling Group"
  type        = number
}

variable "min_size_asg" {
  description = "Min Capacity for Auto Scaling Group"
  type        = number
}

variable "cpu_utilization_scale_up_threshold" {
  description = "CPU utilization threshold to scale up"
  type        = number
  default     = 9
}

variable "cpu_utilization_scale_down_threshold" {
  description = "CPU utilization threshold to scale down"
  type        = number
  default     = 7.5
}

variable "scaling_alarm_period" {
  description = "Scaling Alarm Period"
  type        = number
  default     = 120
}

variable "scaling_policy_cooldown" {
  description = "Scaling Policy Cooldown period"
  type        = number
  default     = 60
}

variable "http_ipv6_cidr" {
  description = "List of IPv6 CIDR ranges for HTTP traffic"
  type        = list(string)
}

variable "https_ipv6_cidr" {
  description = "List of IPv6 CIDR ranges for HTTPS traffic"
  type        = list(string)
}

variable "mailgun_api_key" {
  description = "MailGun API Key"
  type        = string
}

variable "account_id" {
  description = "account id"
  type        = string
}



