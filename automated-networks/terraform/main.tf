provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Criando a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Criando a sub-rede
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true  # Permite a atribuição de IPs públicos

  tags = {
    Name = "main-subnet"
  }
}

# Criando o Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

# Criando a tabela de rotas
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associando a tabela de rotas com a sub-rede
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Criando o grupo de segurança
resource "aws_security_group" "main" {
  name = "security_group_network_sdn"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Web Terminal access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# Gerando par de chaves
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Criando o par de chaves no AWS
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh
}

# Salvando a chave privada localmente
resource "local_file" "private_key" {
  content  = tls_private_key.main.private_key_pem
  filename = "${path.module}/credentials/keypair.pem"
}

# Criando a instância EC2
resource "aws_instance" "web" {
  ami                         = var.image
  instance_type               = "t2.large"
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true
  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size = 30  # Tamanho do volume em GB
    volume_type = "gp2"  # Tipo de volume EBS
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/credentials/keypair.pem")
    host        = aws_instance.web.public_ip
  }

  provisioner "file" {
    source = "../utils/network-components"
    destination = "/home/ubuntu/network-components"
  }
 
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname SDN-Network-EC2",
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com | bash",
      "sudo usermod -aG docker ubuntu",
      "sudo mv network-components ../../opt/",
      "chmod 777 ../../opt/network-components/start.sh",
      "./../../opt/network-components/start.sh"
    ]
  }
}
