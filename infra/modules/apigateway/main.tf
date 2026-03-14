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
  integration_uri    = var.ms_video_uri

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id

  payload_format_version = "1.0"
}

# ─── Rotas autenticadas (JWT) ────────────────────────────────────────────────

resource "aws_apigatewayv2_route" "upload_video" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "POST /videos/upload"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "presign_upload" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "POST /videos/upload/presign"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "confirm_upload" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "POST /videos/confirm/{key}"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "list_videos" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /videos"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "video_status" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /videos/{key}/status"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "download_video" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /videos/download/{key}"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# ─── Rotas públicas (Swagger) ────────────────────────────────────────────────

resource "aws_apigatewayv2_route" "swagger_ui" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /swagger-ui.html"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "swagger_resources" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /swagger-ui/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "openapi_docs" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /v3/api-docs"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "openapi_docs_resources" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "GET /v3/api-docs/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.ms_video.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}
