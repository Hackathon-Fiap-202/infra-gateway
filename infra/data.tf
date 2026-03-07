# Remote state configuration - only used for AWS production
# For LocalStack development, this data source is disabled
# data "terraform_remote_state" "infra_core" {
#   backend = "s3"
#   config = {
#     bucket = "nextime-frame-state-bucket"
#     key    = "infra-core/infra.tfstate"
#     region = "us-east-1"
#   }
# }

# LocalStack/Development: Use local variables instead of remote state
locals {
  # Default values for LocalStack development
  # In production, these would come from the remote infra_core state
  vpc_id             = var.use_localstack ? "vpc-local-dev" : ""
  private_subnet_ids = var.use_localstack ? ["subnet-local-dev"] : []
  security_group_id  = var.use_localstack ? "sg-local-dev" : ""
}
