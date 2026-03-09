# ========================================
# Core Variables
# ========================================

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
  default     = "hackhaton"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "region" {
  description = "AWS Region (backward compatibility)"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "hackhaton"
  }
}

# ========================================
# Cognito Variables
# ========================================

variable "cognito_user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
  default     = "hackhaton-user-pool"
}

variable "cognito_app_client_name" {
  description = "Cognito App Client name"
  type        = string
  default     = "hackhaton-app-client"
}

variable "cognito_password_min_length" {
  description = "Minimum password length for Cognito"
  type        = number
  default     = 8
}

# ========================================
# API Gateway Variables
# ========================================

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
  default     = "hackhaton-api"
}

variable "api_gateway_protocol_type" {
  description = "API Gateway protocol type (HTTP, HTTPS, WEBSOCKET)"
  type        = string
  default     = "HTTP"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "dev"
}
