variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_client_id" {
  type = string
}

variable "vpc_link_id" {
  type = string
}

variable "ms_video_uri" {
  description = "ALB listener ARN for ms-video (required by API Gateway VPC Link integration)"
  type        = string
}