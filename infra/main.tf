module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  region       = var.region
}

module "apigateway" {
  source = "./modules/apigateway"

  project_name         = var.project_name
  region               = var.region
  cognito_user_pool_id = module.cognito.user_pool_id
  cognito_client_id    = module.cognito.user_pool_client_id
  vpc_link_id          = module.vpc_link.vpc_link_id
}

module "vpc_link" {
  source = "./modules/vpc-link"

  project_name    = var.project_name
  vpc_id          = local.vpc_id
  private_subnets = local.private_subnet_ids
  sg_ids = [
    local.security_group_id
  ]
}
