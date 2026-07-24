# ==============================================================================
# ARQUIVO DE VARIAVEIS (variables.tf)
# Objetivo: Centralizar valores dinâmicos para evitar dados fixos no código.
# ==============================================================================

variable "project_name" {
  description = "Nome do projeto para padronizacao das tags dos recursos"
  type        = string
  default     = "capacita-irede"
}

variable "region" {
  description = "Regiao da AWS onde toda a infraestrutura sera provisionada"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco de IPs (CIDR) principal para a nossa rede privada (VPC)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Bloco de IPs (CIDR) para a nossa Sub-rede Publica"
  type        = string
  default     = "10.0.1.0/24"
}
