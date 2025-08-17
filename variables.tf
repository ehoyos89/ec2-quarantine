# Define la región de AWS donde se desplegarán todos los recursos.
variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

# Un nombre para el proyecto, usado para etiquetar y nombrar recursos.
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "ec2_quarantine"
}

# Define el bloque de direcciones IP principal para la VPC.
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Define el bloque de direcciones IP para la subred pública dentro de la VPC.
variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# El ID de la Amazon Machine Image (AMI) que se usará para la instancia EC2.
# Esta AMI corresponde a una versión específica de un sistema operativo.
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0f3f13f145e66a0a3" # Amazon Linux 2
}

# El tipo de instancia para la EC2 (e.g., t2.micro, t3.small, etc.).
# Determina la capacidad de cómputo, memoria y red.
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# El nombre del par de claves (Key Pair) de EC2 para permitir el acceso SSH a la instancia.
# Este par de claves debe existir previamente en la cuenta de AWS.
variable "key_name" {
  description = "The key pair name to use for the EC2 instance"
  type        = string
  default     = "ec2_key"
}

# La dirección de correo electrónico que recibirá las notificaciones de cuarentena de SNS.
# Este es el único valor que no tiene un default, por lo que debe ser proporcionado al ejecutar Terraform.
variable "notification_email" {
  description = "The email address to receive quarantine notifications"
  type        = string
}
