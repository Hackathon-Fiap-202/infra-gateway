# Remote state: infra-core (VPC, subnets, security groups)
data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = "nextime-frame-state-bucket-s3"
    key    = "infra-core/infra.tfstate"
    region = "us-east-1"
  }
}

# Remote state: infra-ecs (ALB DNS for VPC Link integration)
data "terraform_remote_state" "infra_ecs" {
  backend = "s3"
  config = {
    bucket = "nextime-frame-state-bucket-s3"
    key    = "infra-ecs/infra.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id             = data.terraform_remote_state.infra_core.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.infra_core.outputs.private_subnet_ids
  security_group_id  = data.terraform_remote_state.infra_core.outputs.security_group_api_id
  # ms-video ALB DNS — used by API Gateway VPC Link integration
  ms_video_alb_uri = "http://${data.terraform_remote_state.infra_ecs.outputs.alb_dns_name}"
}
