# Define el grupo de seguridad principal para la instancia EC2 en estado normal.
resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance"

  # Regla de entrada: permite el acceso SSH desde cualquier dirección IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  # Regla de entrada: permite el acceso HTTP desde cualquier dirección IP.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  # Regla de salida: permite todo el tráfico saliente a cualquier destino.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" significa todos los protocolos.
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# Define el grupo de seguridad que se usará para poner en cuarentena a las instancias.
resource "aws_security_group" "quarantine" {
  name        = "quarantine-sg"
  description = "Deny all traffic for quarantined instances"
  vpc_id      = aws_vpc.main.id

  # Al definir una lista vacía de reglas de entrada, se bloquea todo el tráfico entrante.
  ingress = []

  # Al definir una lista vacía de reglas de salida, se bloquea todo el tráfico saliente.
  # Esto aísla completamente la instancia de la red.
  egress = []

  tags = {
    Name = "quarantine-sg"
  }
}
