provider "aws" {
  region = "us-east-1"  # Puedes cambiar la región si lo deseas
}

# Crear VPC en us-east-1
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "basic-terraform-vpc"
  }
}

# Crear Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Crear tabla de rutas para la VPC
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "basic-route-table"
  }
}

# Asociar la tabla de rutas a la subred
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Crear subred pública en us-east-1
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Puedes cambiar la zona de disponibilidad si lo deseas

  tags = {
    Name = "basic-public-subnet"
  }
}

# Crear grupo de seguridad para permitir tráfico HTTP y SSH
resource "aws_security_group" "sg" {
  name        = "basic-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acceso SSH desde cualquier IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfico HTTP desde cualquier IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir todo el tráfico saliente
  }
}

# Lanzar una instancia EC2 básica (utilizando Amazon Linux)
resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amazon_linux.id # Usar AMI de Amazon Linux más reciente
  instance_type = "t2.micro" # Tipo de instancia gratuita

  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "BasicWebServer"
  }
}

# Obtener la AMI más reciente de Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"] # Propietario de Amazon Linux AMI

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Salida: dirección IP pública del servidor web
output "Webserver-Public-IP" {
  value = aws_instance.webserver.public_ip
}
