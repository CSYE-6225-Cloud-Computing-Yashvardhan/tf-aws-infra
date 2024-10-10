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
