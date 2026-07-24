# ==============================================================================
# ARQUIVO DE MENSAGERIA (sqs.tf)
# Objetivo: Criar a fila assincrona que intermediara a API e o Processamento.
# ==============================================================================

resource "aws_sqs_queue" "pedidos_queue" {
  name                      = "pedidos-a-processar" # Nome exato exigido pelo projeto
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB (Tamanho maximo padrao da mensagem)
  message_retention_seconds = 86400  # Tempo de vida da mensagem na fila: 1 dia (24h)

  tags = {
    Name = "pedidos-a-processar"
  }
}
