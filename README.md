# Projeto de Infraestrutura como Código (IaC) com Terraform e AWS

Este projeto consiste na implantação automatizada de uma arquitetura resiliente e escalável na AWS utilizando Terraform. A infraestrutura provê uma API em Python/Flask hospedada em uma instância EC2, integrada ao serviço de mensageria AWS SQS para processamento assíncrono de pedidos via AWS Lambda.

---

## 🏛️ Arquitetura da Solução

* **VPC & Subnet Pública:** Rede isolada e configurada com navegação via Internet Gateway.
* **Security Group:** Regras de firewall liberando as portas `22` (SSH) e `5000` (API Flask).
* **EC2 (Ubuntu ARM / t4g.micro):** Servidor onde a aplicação Python/Flask é executada via script de inicialização (`user_data`).
* **IAM Instance Profile:** Concede permissões para a EC2 enviar mensagens diretamente para o AWS SQS sem a necessidade de credenciais estáticas.
* **AWS SQS (Simple Queue Service):** Fila de mensagens assíncrona (`pedidos-a-processar`) que recebe as requisições enviadas pela API.
* **AWS Lambda & CloudWatch:** Função serverless acionada para consumo de eventos da fila SQS e geração de registros de auditoria no CloudWatch.

---

## 🚀 Como Executar o Terraform

1. **Pré-requisitos:**
   * Terraform instalado.
   * AWS CLI configurado com credenciais válidas.

2. **Inicializar o Terraform:**
   ```bash
   terraform init


