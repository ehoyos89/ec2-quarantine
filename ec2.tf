# Define una instancia EC2 que sirve como servidor de prueba para este proyecto.
# El propósito de esta instancia es tener un recurso que pueda ser puesto en cuarentena.
resource "aws_instance" "test_server" {
  ami           = var.ami_id # Amazon Machine Image: la plantilla del sistema operativo.
  instance_type = var.instance_type # El tamaño de la instancia (e.g., t2.micro).
  key_name      = var.key_name # El par de claves SSH para acceder a la instancia.

  subnet_id                   = aws_subnet.public_subnet.id # Se lanza en la subred pública.
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id] # Se asocia con el grupo de seguridad principal.

  # user_data ejecuta un script al iniciar la instancia por primera vez.
  # En este caso, instala un servidor web simple.
  user_data = templatefile("${path.module}/user_data.sh", {})

  tags = {
    Name = "${var.project_name}-test-server"
  }
}
