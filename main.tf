# Define a região AWS a ser usada
provider "aws" {
  region = "us-east-1"
}

# Cria um bucket S3
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "nome-do-seu-bucket"
  acl    = "private"

  tags = {
    Name        = "Bucket do Frontend do FutBet"
    Environment = "Production"
  }
}

# Cria uma instância EC2
resource "aws_instance" "backend_instance" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  key_name      = "nome-da-sua-chave"
  user_data     = <<-EOF
    #!/bin/bash
    git clone https://github.com/seu-usuario/nome-do-repositorio.git
    cd nome-do-repositorio/backend
    npm install
    nohup node app.js &
    EOF

  tags = {
    Name        = "Instância do Backend do FutBet"
    Environment = "Production"
  }

  # Configura a instância EC2 para permitir tráfego HTTP
  security_groups = [
    aws_security_group.backend_security_group.id,
  ]
}

# Configura o grupo de segurança para permitir tráfego HTTP
resource "aws_security_group" "backend_security_group" {
  name_prefix = "backend-"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configura a permissão do bucket S3 para permitir acesso público
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}/*",
        ]
      },
    ]
  })
}