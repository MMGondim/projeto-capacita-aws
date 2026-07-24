# ==============================================================================
# ARQUIVO SERVERLESS (lambda.tf)
# Objetivo: Criar a funcao automatica, permissões e vinculá-la à fila do SQS.
# ==============================================================================

# 1. Cria a Role (Perfil) do IAM para dar permissoes para a nossa funcao Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. Anexa a politica para a Lambda conseguir escrever logs no CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Anexa a politica para a Lambda conseguir ler/consumir dados da fila do SQS
resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# 4. Cria o arquivo ZIP temporario contendo o codigo em Python da nossa Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source {
    filename = "index.py"
    content  = <<EOF
def lambda_handler(event, context):
    # Passa por cada registro enviado pela fila do SQS
    for record in event['Records']:
        pedido = record['body']
        # O comando print envia automaticamente o log para o CloudWatch Logs
        print(f"PROCESSAMENTO CONCLUIDO -> Mensagem recebida do SQS: {pedido}")
    return {'statusCode': 200}
EOF
  }
}

# 5. Define e faz o upload da funcao AWS Lambda para a nuvem
resource "aws_lambda_function" "process_pedidos" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "processa-pedidos-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"

  tags = {
    Name = "processa-pedidos-lambda"
  }
}

# 6. Cria o Trigger (Gatilho) mapeando o SQS para disparar a Lambda automaticamente
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.pedidos_queue.arn
  function_name    = aws_lambda_function.process_pedidos.arn
  batch_size       = 10 # Processa ate 10 mensagens por vez para economizar recursos
}
