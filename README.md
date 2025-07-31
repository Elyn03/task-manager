# Task Manager

## 📝 Description

Task Manager est une application web permettant de gérer des tâches (CRUD) avec une API REST déployée sur AWS.  
Le projet utilise Terraform pour l’infrastructure as code, AWS Lambda pour la logique métier, DynamoDB pour le stockage, S3 pour l’hébergement du frontend, et CloudFront pour la distribution.

## ✨ Fonctionnalités

- Création, lecture, modification et suppression de tâches
- Interface web statique hébergée sur S3
- API sécurisée via IAM et Lambda
- Infrastructure automatisée avec Terraform
- CI/CD via GitHub Actions

## ⚙️ Configuration & Déploiement

### 📋 Prérequis

- Compte AWS avec droits administrateur
- VPC en europe : eu-west-1
- GitHub Actions configuré avec les secrets AWS
- AWS CLI configuré avec vos identifiants
- Terraform installé (version >= 1.0)
- Node.js (version >= 18)
- Docker installé

### 🛠️ Configuration

1. Récupérer le projet
```bash
git clone https://github.com/Elyn03/task-manager.git
cd task-manager
```
2. Configurer AWS CLI
```bash
aws configure

# AWS Access Key ID
# AWS Secret Access Key
# Default region name: eu-west-1
# Default output format: json

aws sts get-caller-identity
```

3. Dans `infra/terraform.tfvars` ou via variables d’environnement :

```hcl
bucket_name         = "task-manager"
tags                = { "Project" = "TaskManager" }
sync_directories    = [{ local_source_directory = "./frontend/dist", s3_target_directory = "" }]
mime_types          = { "html" = "text/html", "js" = "application/javascript", "css" = "text/css" }
```

### 🔑 Secrets GitHub

| Nom du secret           | Valeur         |
| :---------------        |:--------------:|
| `AWS_ACCESS_KEY_ID`     | clé d'accès AWS|
| `AWS_SECRET_ACCESS_KEY` | clé secrète AWS|
| `AWS_IAM_ROLE`          | role IAM       |
| `DOCKER_USERNAME`       | personal access token ID Docker|
| `DOCKER_PASSWORD`       | personal access token MDP Docker|


### 🚀 Déploiement

```bash
# Initialiser Terraform
terraform init

# Vérifier le plan
terraform plan

# Appliquer l’infrastructure
terraform apply
```

Le frontend sera disponible via l’URL CloudFront générée.

## 🗂️ Structure du projet

```
task-manager/
├── .github/workflows/  # Pipeline CI/CD
│   └── deploy.yml
├── client/             # Application React
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── server/             # API Node.js
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── infra/              # Terraform
│   ├── apigateway.tf
│   ├── cloudfront.tf
│   ├── dynamodb.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── terraform.tfstate
├── .dockerignore
├── .gitignore
├── docker-compose.yml
└── README.md
```

---
Projet réalisé dans le cadre du module DevOps à l’IIM.