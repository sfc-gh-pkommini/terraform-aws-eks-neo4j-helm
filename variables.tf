# Required Variables
variable "module_prefix" {
  description = "Prefix name to the resources."
  type        = string
}

variable "neo4j_helm_chart_version" {
  description = "neo4j Helm Chart version."
  type        = string
  default     = "5.21.2"
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created."
  type        = string
}


variable "neo4j_root_user_password" {
  description = "The password used to login for the first time."
  type        = string
}

variable "hosted_zone_subdomain" {
  description = "Hosted zone subdomain name on which neo4j hostname will be created."
  type        = string
}

variable "subdomain_cert_arn" {
  description = "ACM SSL Cert ARN for the neo4j host name."
  type        = string
}

# OPTIONAL VARIABLES
variable "env" {
  description = "Environment to be test/dev/prod."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Name of the app."
  type        = string
  default     = "neo4j"
}

variable "domain_name_suffix" {
  description = "Suffix for neo4j domain hostname."
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks that can initiate connections to neo4j."
  type        = list(string)
  default     = []
}

variable "adhoc_cidr_blocks" {
  description = "Allowed adhoc CIDR blocks that can initiate connections to neo4j."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Allowed SG IDs that can initiate connections to neo4j."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to allow to connect to Sentry private loadbalancer."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Publlic subnet IDs to allow to connect to neo4j public loadbalancer."
  type        = list(string)
  default     = []
}

variable "dependency_update" {
  description = "Dependency update flag flag."
  type        = bool
  default     = false
}

variable "wait" {
  description = "wait flag."
  type        = bool
  default     = false
}

variable "logs_bucket_name" {
  description = "S3 Bucket's name (or id) to store load balancer logs."
  type        = string
  default     = null
}

variable "node_security_group_id" {
  description = "Node security group IDs."
  type        = string
}

variable "cluster_security_group_id" {
  description = "Node security group IDs."
  type        = string
  default     = null
}

locals {
  neo4j_dns_name = var.domain_name_suffix != null ? "${var.app_name}-${var.domain_name_suffix}.${var.hosted_zone_subdomain}" : "${var.app_name}.${var.hosted_zone_subdomain}"
  neo4j_admin_dns_name = var.domain_name_suffix != null ? "${var.app_name}-${var.domain_name_suffix}.${var.hosted_zone_subdomain}" : "${var.app_name}.${var.hosted_zone_subdomain}"
}
