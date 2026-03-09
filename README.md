# Infra-Gateway

Repositório contendo a infraestrutura do API Gateway do projeto Nextime Frame, provisionada com Terraform na AWS.

## 📋 Descrição

Este projeto define a infraestrutura como código (IaC) para criar um API Gateway HTTP na AWS com autenticação JWT via Amazon Cognito. A infraestrutura inclui:

- **API Gateway HTTP API v2**: Gateway HTTP moderno com auto-deploy habilitado
- **Amazon Cognito**: User Pool e Client para autenticação e autorização
- **VPC Link**: Conexão segura entre o API Gateway e recursos privados na VPC

## 🏗️ Arquitetura

O projeto é organizado em módulos Terraform reutilizáveis:

```
infra/
├── main.tf                 # Configuração principal dos módulos
├── variables.tf            # Variáveis do módulo raiz
├── outputs.tf              # Outputs da infraestrutura
├── providers.tf            # Configuração de providers e backend
├── data.tf                 # Data sources
├── terraform.tfvars        # Valores das variáveis
└── modules/
    ├── apigateway/         # Módulo do API Gateway
    ├── cognito/            # Módulo do Cognito User Pool
    └── vpc-link/           # Módulo do VPC Link
```

## 🔧 Componentes

### API Gateway (`modules/apigateway`)
- Cria um API Gateway HTTP API v2
- Configura autorizador JWT integrado com Cognito
- Suporta integração com serviços privados via VPC Link
- Stage padrão com auto-deploy habilitado

### Cognito (`modules/cognito`)
- User Pool configurado com:
  - Autenticação via email
  - Verificação automática de email
  - Política de senha (mínimo 8 caracteres, maiúsculas, minúsculas e números)
- User Pool Client configurado com:
  - Fluxos de autenticação: USER_PASSWORD_AUTH, USER_SRP_AUTH, REFRESH_TOKEN_AUTH
  - Sem secret (para aplicações públicas)

### VPC Link (`modules/vpc-link`)
- Conecta o API Gateway a recursos privados na VPC
- Utiliza subnets privadas e security groups da infraestrutura core

## 📦 Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- AWS CLI configurado com credenciais apropriadas
- Acesso ao bucket S3 `nextime-frame-state-bucket-s3` para o backend remoto
- Estado remoto do módulo `infra-core` disponível no mesmo bucket

## 🚀 Como Usar

### 1. Configurar Variáveis

Edite o arquivo `infra/terraform.tfvars` com os valores apropriados:

```hcl
project_name = "nextime-frame"
region = "us-east-1"
```

### 2. Inicializar Terraform

```bash
cd infra
terraform init
```

### 3. Revisar o Plano

```bash
terraform plan
```

### 4. Aplicar a Infraestrutura

```bash
terraform apply
```

## 📤 Outputs

Após a aplicação, os seguintes outputs estarão disponíveis:

- `api_gateway_invoke_url`: URL de invocação do API Gateway
- `api_gateway_authorizer_id`: ID do autorizador JWT
- `api_gateway_id`: ID do API Gateway
- `api_endpoint`: Endpoint do API Gateway
- `cognito_user_pool_id`: ID do User Pool do Cognito
- `cognito_user_pool_client_id`: ID do Client do Cognito
- `vpc_link_id`: ID do VPC Link

Para visualizar os outputs:

```bash
terraform output
```

## 🔐 Autenticação

O API Gateway está configurado com autorização JWT usando Cognito. Para usar as rotas protegidas:

1. Autentique-se no Cognito User Pool
2. Obtenha o token JWT
3. Inclua o token no header `Authorization` das requisições

## 🔗 Integração com Microserviços

O módulo do API Gateway inclui código comentado para integração com microserviços privados. Para adicionar uma rota:

1. Descomente e configure o recurso `aws_apigatewayv2_integration`
2. Configure a rota correspondente em `aws_apigatewayv2_route`
3. Especifique o ARN do listener do NLB do microserviço

Exemplo (comentado no código):
```hcl
resource "aws_apigatewayv2_integration" "ms_video" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  integration_method = "POST"
  integration_uri    = var.ms_video_nlb_listener_arn
  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id
}
```

## 🌐 Backend Remoto

O estado do Terraform é armazenado remotamente no S3:

- **Bucket**: `nextime-frame-state-bucket-s3`
- **Key**: `gateway/infra.tfstate`
- **Região**: `us-east-1`
- **Criptografia**: Habilitada

## 🔄 Dependências

Este módulo depende do estado remoto do módulo `infra-core` para obter:
- VPC ID
- IDs das subnets privadas
- Security Group ID da API

O estado remoto é acessado via:
- **Bucket**: `nextime-frame-state-bucket-s3`
- **Key**: `infra-core/infra.tfstate`

## 📝 Versões

- **AWS Provider**: 6.14.1
- **Terraform**: >= 1.0

## 🛠️ Manutenção

### Atualizar Infraestrutura

```bash
cd infra
terraform plan
terraform apply
```

### Destruir Infraestrutura

⚠️ **Atenção**: Isso removerá todos os recursos criados.

```bash
cd infra
terraform destroy
```

## 📄 Licença

Este projeto faz parte do hackathon SOAT.

## 👥 Contribuição

Para contribuir com este projeto, siga as práticas padrão de Terraform e mantenha a estrutura modular.
