# El bloque 'terraform' se utiliza para configurar el comportamiento de Terraform.
terraform {
  # Especifica la versión mínima de Terraform requerida para ejecutar este código.
  required_version = ">= 1.0.0"

  # Define los proveedores de Terraform necesarios para este proyecto.
  required_providers {
    # El proveedor 'aws' es necesario para interactuar con los servicios de Amazon Web Services.
    aws = {
      source  = "hashicorp/aws" # El origen oficial del proveedor de AWS es HashiCorp.
      version = ">= 5.0"      # Especifica la versión mínima del proveedor de AWS compatible.
    }
  }
}
