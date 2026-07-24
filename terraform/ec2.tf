# ==============================================================================
# ARQUIVO DE COMPUTAÇÃO (ec2.tf)
# Objetivo: Instanciar o servidor Linux com Role IAM e implantar as APIs.
# ==============================================================================

# 1. Busca dinamicamente a imagem oficial mais recente do Ubuntu Server (ARM)
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
  owners = ["099720109477"] # ID Oficial da Canonical
}

# 2. Perfil de Instância IAM para vincular a Role do SQS à máquina EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_sqs_role.name
}

# 3. Role IAM para a EC2 conseguir enviar mensagens para o SQS
resource "aws_iam_role" "ec2_sqs_role" {
  name = "${var.project_name}-ec2-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 4. Anexa a política de acesso total ao SQS para a Role da EC2
resource "aws_iam_role_policy_attachment" "ec2_sqs_policy" {
  role       = aws_iam_role.ec2_sqs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# 5. Provisiona o servidor EC2 com o perfil IAM anexado
resource "aws_instance" "api_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t4g.micro"
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Script de User Data: Instala dependências e inicia a API Flask
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3-pip python3-flask
              pip3 install boto3
              
              mkdir -p /home/ubuntu/app
              
              cat << 'APPEOF' > /home/ubuntu/app/app.py
              from flask import Flask, jsonify, request
              import boto3
              import json

              app = Flask(__name__)
              
              sqs = boto3.client('sqs', region_name='${var.region}')
              QUEUE_URL = '${aws_sqs_queue.pedidos_queue.id}'

              # --- ROTA 1: API de Produtos (GET) ---
              @app.route('/produtos', methods=['GET'])
              def listar_produtos():
                  produtos = [
                      {"id": 1, "nome": "Tablet Samsung S10 Lite", "preco": 2499.00},
                      {"id": 2, "nome": "Capa Teclado Bluetooth", "preco": 349.90},
                      {"id": 3, "nome": "Caneta Stylus S-Pen", "preco": 199.00}
                  ]
                  return jsonify(produtos), 200

              # --- ROTA 2: API de Pedidos (POST) ---
              @app.route('/pedidos', methods=['POST'])
              def criar_pedido():
                  dados_pedido = request.json
                  
                  resposta_aws = sqs.send_message(
                      QueueUrl=QUEUE_URL,
                      MessageBody=json.dumps(dados_pedido)
                  )
                  
                  return jsonify({
                      "status": "Pedido enviado para o SQS com sucesso!", 
                      "message_id": resposta_aws['MessageId']
                  }), 201

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              APPEOF

              nohup python3 /home/ubuntu/app/app.py > /home/ubuntu/app/app.log 2>&1 &
              EOF

  tags = {
    Name = "API-Produtos-Pedidos-Server"
  }
}

# 6. Output do IP público da instância
output "ec2_public_ip" {
  description = "IP Publico gerado para acessarmos as nossas APIs"
  value       = aws_instance.api_server.public_ip
}

