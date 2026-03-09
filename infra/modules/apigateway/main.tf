resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["*"]
    allow_methods  = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
  }
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.this.id
  authorizer_type = "JWT"
  name            = "cognito-authorizer"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}


resource "aws_apigatewayv2_integration" "ms_video" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "${var.ms_video_uri}/{proxy}"

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "upload_video" {
  api_id = aws_apigatewayv2_api.this.id

  route_key = "POST /videos/upload"

  target = "integrations/${aws_apigatewayv2_integration.ms_video.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# Rota genérica para Swagger e outros endpoints públicos (SEM autenticação)
resource "aws_apigatewayv2_route" "proxy" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "ANY /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}
