output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "authorizer_id" {
  value = aws_apigatewayv2_authorizer.cognito.id
}

output "api_gateway_invoke_url" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.this.id
}

output "upload_video_route_id" {
  value       = aws_apigatewayv2_route.upload_video.id
  description = "Route ID for POST /videos/upload"
}
