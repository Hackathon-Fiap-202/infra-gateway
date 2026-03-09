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

variable "use_localstack" {
  type    = bool
  default = true
}

variable "ms_video_uri" {
  description = "MS Video microservice URI (e.g., http://ms-video:8090)"
  type        = string
  default     = "http://ms-video:8090"
}