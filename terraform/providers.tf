# ==============================================================================
# ARQUIVO DE PROVEDORES (providers.tf)
# Objetivo: Declarar qual provedor de nuvem (AWS) e versao o Terraform deve usar.
# ==============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Garante o uso da versao estável 5.x da AWS
    }
  }
}

# Inicializa o provedor utilizando a regiao definida nas variaveis
provider "aws" {
  region = var.region
}
