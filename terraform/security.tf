# ==============================================================================
# ARQUIVO DE SEGURANCA (security.tf)
# Objetivo: Controlar o fluxo de entrada e saida de dados para a nossa EC2.
# ==============================================================================

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Liberar portas HTTP (5000) para as APIs e SSH (22) para gerencia"
  vpc_id      = aws_vpc.main.id

  # Regra de Entrada (Ingress): Permite acesso SSH para administracao
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Aberto para testes (pode ser restrito em producao)
  }

  # Regra de Entrada (Ingress): Permite chamadas HTTP na porta 5000 (onde rodara o Flask)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite que qualquer usuario acesse as APIs de qualquer lugar
  }

  # Regra de Saída (Egress): Permite que a EC2 acesse a internet (para baixar pacotes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Significa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}
