resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.this.id
  authorizer_type = "JWT"
  name            = "cognito-authorizer"

  identity_sources = ["$request.header.Authorization"]

  authorizer_payload_format_version = "2.0"

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}


# Descomentar para criar integração com o microserviço de vídeo
# resource "aws_apigatewayv2_integration" "ms_video" {
#   api_id           = aws_apigatewayv2_api.this.id
#   integration_type = "HTTP_PROXY"
#
#   integration_method = "POST"
#   integration_uri    = var.ms_video_nlb_listener_arn
#
#   connection_type = "VPC_LINK"
#   connection_id   = var.vpc_link_id
# }

# resource "aws_apigatewayv2_route" "upload_video" {
#   api_id = aws_apigatewayv2_api.this.id
#
#   route_key = "POST /videos/upload"
#
#   target = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
#
#   authorization_type = "JWT"
#   authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
# }

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}
