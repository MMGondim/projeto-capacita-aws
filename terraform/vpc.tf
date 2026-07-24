# ==============================================================================
# ARQUIVO DE REDE (vpc.tf)
# Objetivo: Criar a malha de rede isolada e segura para abrigar servidores.
# ==============================================================================

# 1. Cria a VPC (Virtual Private Cloud) - Datacenter virtual
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # Obrigatorio para a EC2 conseguir resolver nomes internos
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Cria a Sub-rede Pública (Subnet) onde a EC2 ficará alocada
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true # Garante que as instancias ganhem um IP publico ao ligar
  availability_zone       = "${var.region}a" # Zona de disponibilidade 'a' da regiao

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# 3. Cria o Internet Gateway (IGW) - A ponte de conexao com a internet externa
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 4. Cria a Tabela de Roteamento (Route Table) para guiar o trafego para a internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Qualquer trafego externo...
    gateway_id = aws_internet_gateway.igw.id # ...deve ser enviado para o Internet Gateway
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 5. Associa a Tabela de Roteamento criada especificamente à nossa Sub-rede Pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
