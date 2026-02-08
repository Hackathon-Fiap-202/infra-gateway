data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = "nextime-frame-state-bucket"
    key    = "infra-core/infra.tfstate"
    region = "us-east-1"
  }
}
