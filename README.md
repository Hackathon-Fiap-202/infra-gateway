# infra-gateway

Infraestrutura do API Gateway e autenticação do projeto **nexTime-frame**, provisionada com Terraform na AWS. Este repositório define o Amazon Cognito (User Pool + App Client), o API Gateway HTTP v2 com autorizador JWT, o VPC Link para roteamento interno e todas as rotas expostas aos clientes.

## Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Fluxo de Autenticação](#fluxo-de-autenticação)
- [Recursos Provisionados](#recursos-provisionados)
- [Rotas do API Gateway](#rotas-do-api-gateway)
- [Pré-requisitos](#pré-requisitos)
- [Variáveis](#variáveis)
- [Outputs](#outputs)
- [Como Usar](#como-usar)
- [Backend Remoto](#backend-remoto)
- [CI/CD](#cicd)
- [Ordem de Deploy](#ordem-de-deploy)
- [Contribuição](#contribuição)

---

## Visão Geral

O `infra-gateway` é o **terceiro stack a ser aplicado** na ordem de deploy. Ele depende dos outputs do `infra-core` (VPC, subnets privadas, security group) e do `Infra-ecs` (ARN do ALB Listener).

> **Atenção**: este stack **deve ser reaplicado toda vez que o `Infra-ecs` for reaplicado**, pois o ARN do ALB Listener é atualizado e a integração do API Gateway aponta para o ARN anterior, causando erros 500.

---

## Arquitetura

```
Cliente (mobile / web)
      │
      │  HTTPS  Authorization: Bearer <JWT>
      ▼
API Gateway HTTP v2  (aws_apigatewayv2_api)
      │
      ├── Autorizador JWT → Cognito User Pool
      │                      (valida token, extrai sub → X-Cognito-User-Id)
      │
      │  VPC Link (aws_apigatewayv2_vpc_link)
      ▼
Internal ALB  (subnets privadas)
      ▼
ms-video  (ECS Fargate, port 8090)
```

---

## Fluxo de Autenticação

1. O cliente registra-se ou autentica-se no **Cognito User Pool**
2. O Cognito retorna um **token JWT** (ID Token ou Access Token)
3. O cliente inclui o token no header `Authorization: Bearer <token>` em cada requisição
4. O API Gateway valida o JWT via o **autorizador Cognito**
5. Após validação bem-sucedida, o API Gateway encaminha a requisição ao ms-video via VPC Link, adicionando o header `X-Cognito-User-Id` com o `sub` do usuário

---

## Recursos Provisionados

### Cognito (`modules/cognito`)

| Recurso | Configuração |
|---|---|
| `aws_cognito_user_pool` | Username = email; verificação de email automática; senha mínima 8 caracteres (letras minúsculas + maiúsculas + números obrigatórios) |
| `aws_cognito_user_pool_client` | Fluxos: `ALLOW_USER_PASSWORD_AUTH`, `ALLOW_USER_SRP_AUTH`, `ALLOW_REFRESH_TOKEN_AUTH`; sem client secret (aplicações públicas) |

### API Gateway (`modules/apigateway`)

| Recurso | Configuração |
|---|---|
| `aws_apigatewayv2_api` | HTTP API v2, CORS habilitado (todas as origens, métodos e headers) |
| `aws_apigatewayv2_authorizer` | Tipo JWT, audience = Cognito App Client ID, issuer = Cognito User Pool URL |
| `aws_apigatewayv2_stage` | Stage `$default`, auto-deploy habilitado |
| `aws_apigatewayv2_integration` | `HTTP_PROXY` via VPC Link → ALB Listener ARN |

### VPC Link (`modules/vpc-link`)

| Recurso | Configuração |
|---|---|
| `aws_apigatewayv2_vpc_link` | Conecta o API Gateway às subnets privadas do `infra-core`; usa o security group da API |

---

## Rotas do API Gateway

| Método | Rota | Autenticação | Destino |
|---|---|---|---|
| `POST` | `/videos/upload` | JWT (Cognito) | ms-video — upload direto multipart (legado) |
| `POST` | `/videos/upload/presign` | JWT (Cognito) | ms-video — gera URL pré-assinada S3 |
| `POST` | `/videos/confirm/{key}` | JWT (Cognito) | ms-video — confirma upload no S3 |
| `ANY` | `/{proxy+}` | Nenhuma | Catch-all sem auth (Swagger, actuator, etc.) |

---

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Estado remoto do `infra-core` disponível em `nextime-frame-state-bucket-s3`
- Estado remoto do `Infra-ecs` disponível (para o ARN do ALB Listener)

---

## Variáveis

| Variável | Tipo | Descrição | Padrão |
|---|---|---|---|
| `project_name` | `string` | Prefixo de todos os recursos | `nextime-frame` |
| `region` | `string` | Região AWS | `us-east-1` |
| `tags` | `map(string)` | Tags aplicadas a todos os recursos | `{ Owner = "nexTime-frame" }` |

---

## Outputs

Lidos pelo `lambda-sender` via `terraform_remote_state`:

| Output | Descrição |
|---|---|
| `api_gateway_invoke_url` | URL de invocação do API Gateway (base URL para os clientes) |
| `api_gateway_id` | ID do API Gateway |
| `api_endpoint` | Endpoint do API Gateway |
| `api_gateway_authorizer_id` | ID do autorizador JWT |
| `cognito_user_pool_id` | ID do Cognito User Pool — usado pelo `lambda-sender` para `AdminGetUser` |
| `cognito_user_pool_client_id` | ID do App Client do Cognito |
| `vpc_link_id` | ID do VPC Link |

---

## Como Usar

```bash
cd infra-gateway/infra

# Inicializar
terraform init

# Validar
terraform validate

# Plano
terraform plan

# Aplicar
terraform apply

# Ver outputs (URL do API Gateway, Cognito Pool ID, etc.)
terraform output
```

---

## Backend Remoto

```hcl
backend "s3" {
  bucket  = "nextime-frame-state-bucket-s3"
  key     = "infra-gateway/infra.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

**Data sources remotos consumidos:**

| Stack | Bucket Key | Dados utilizados |
|---|---|---|
| `infra-core` | `infra-core/infra.tfstate` | `vpc_id`, `private_subnet_ids`, `security_group_api_id` |
| `Infra-ecs` | `infra-ecs/infra.tfstate` | `alb_listener_arn` |

---

## CI/CD

O pipeline `.github/workflows/cd-infra.yml` é acionado em push para `main`.

| Etapa | Comando |
|---|---|
| Configure AWS | OIDC via `AWS_ROLE_ARN` |
| Init | `terraform init` |
| Validate | `terraform validate` |
| Plan | `terraform plan` |
| Apply | `terraform apply -auto-approve` |

**Secrets do GitHub necessários:**

| Secret | Descrição |
|---|---|
| `AWS_ACCOUNT_ID` | ID da conta AWS |
| `AWS_ROLE_ARN` | ARN da role com permissões de deploy |

---

## Ordem de Deploy

```
1. infra-core
2. infra-messaging
3. infra-gateway      ← este repositório (aplicar antes e depois do Infra-ecs)
4. Infra-ecs
   └── ⚠️  Reaplicar infra-gateway após cada apply do Infra-ecs
5. lambda-sender
```

---

## Estrutura do Projeto

```
infra-gateway/
├── infra/
│   ├── main.tf              # Instancia os módulos cognito, apigateway e vpc-link
│   ├── variables.tf         # Declaração de variáveis
│   ├── outputs.tf           # Outputs exportados
│   ├── providers.tf         # Provider AWS + backend S3
│   ├── data.tf              # Data sources (remote state do infra-core e Infra-ecs)
│   ├── terraform.tfvars     # Valores das variáveis
│   └── modules/
│       ├── apigateway/      # API Gateway HTTP v2, autorizador JWT, rotas, integração
│       ├── cognito/         # User Pool + App Client
│       └── vpc-link/        # VPC Link nas subnets privadas
└── README.md
```

---

## Contribuição

Este repositório faz parte do hackathon FIAP — nexTime-frame. Siga o padrão de commits convencional (`feat:`, `fix:`, `docs:`, `chore:`) e mantenha a estrutura modular do Terraform.
