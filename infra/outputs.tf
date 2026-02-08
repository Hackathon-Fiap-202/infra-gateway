output "api_gateway_invoke_url" {
  value = module.apigateway.api_gateway_invoke_url
}

output "api_gateway_authorizer_id" {
  value = module.apigateway.authorizer_id
}

output "api_gateway_id" {
  value = module.apigateway.api_gateway_id
}

output "api_endpoint" {
  value = module.apigateway.api_endpoint
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "vpc_link_id" {
  value = module.vpc_link.vpc_link_id
}
