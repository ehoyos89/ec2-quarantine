# Define la Virtual Private Cloud (VPC), que es una red virtual aislada en AWS.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block # Rango de direcciones IP para la VPC.
  enable_dns_support   = true # Permite la resolución de DNS dentro de la VPC.
  enable_dns_hostnames = true # Asigna nombres de host DNS a las instancias.
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Define una subred pública dentro de la VPC.
# Una subred es un rango de IPs dentro de la VPC donde se pueden lanzar recursos.
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block # Rango de IP para la subred.
  map_public_ip_on_launch = true # Asigna automáticamente una IP pública a las instancias lanzadas aquí.
  availability_zone       = "${var.aws_region}a" # Zona de disponibilidad para la subred.
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Define un Internet Gateway (IGW) para permitir la comunicación entre la VPC e Internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Define una tabla de rutas para la subred pública.
# Las tablas de rutas determinan a dónde se dirige el tráfico de red.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  # Define una ruta por defecto: todo el tráfico (0.0.0.0/0) se dirige al Internet Gateway.
  # Esto es lo que hace que la subred sea "pública".
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# Asocia la tabla de rutas pública con la subred pública.
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
