# EC2 Quarantine System

Un sistema automatizado de cuarentena para instancias EC2 basado en hallazgos de AWS GuardDuty, implementado con Terraform e infraestructura como código.

## 🎯 Descripción del Proyecto

Este proyecto implementa una solución de seguridad automatizada que detecta amenazas en instancias EC2 mediante AWS GuardDuty y las pone automáticamente en cuarentena para prevenir la propagación de posibles compromisos de seguridad.

### Flujo de Funcionamiento

1. **Detección**: AWS GuardDuty detecta actividad sospechosa en una instancia EC2
2. **Activación**: EventBridge captura el hallazgo de severidad alta/crítica
3. **Cuarentena**: Lambda función modifica los grupos de seguridad de la instancia
4. **Notificación**: Se envía una alerta por email vía SNS al administrador

## 🏗️ Arquitectura

```
GuardDuty → EventBridge → Lambda Function → EC2 Instance (Quarantine)
                    ↓
                  SNS Topic → Email Notification
```

### Componentes

- **VPC y Red**: Infraestructura de red aislada con subred pública
- **EC2 Instance**: Servidor de prueba para demostrar la cuarentena
- **GuardDuty**: Servicio de detección de amenazas
- **EventBridge**: Orquestador de eventos basado en reglas
- **Lambda Function**: Lógica de cuarentena automatizada
- **SNS**: Sistema de notificaciones por email
- **Security Groups**: Grupos de seguridad normal y de cuarentena

## 📋 Requisitos Previos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configurado con credenciales válidas
- Un par de claves (Key Pair) existente en AWS EC2
- Dirección de email válida para recibir notificaciones

## 🚀 Instalación y Despliegue

### 1. Clonar y Configurar

```bash
git clone <repository-url>
cd ec2_quarantine
```

### 2. Configurar Variables

Crea un archivo `terraform.tfvars` o exporta las variables de entorno:

```hcl
# terraform.tfvars
aws_region         = "us-east-1"
project_name       = "ec2-quarantine"
notification_email = "tu-email@ejemplo.com"
key_name          = "tu-key-pair"
```

### 3. Inicializar Terraform

```bash
terraform init
```

### 4. Revisar el Plan

```bash
terraform plan
```

### 5. Desplegar la Infraestructura

```bash
terraform apply
```

### 6. Confirmar la Suscripción de Email

Después del despliegue, recibirás un email de confirmación de AWS SNS que debes aceptar.

## 🔧 Configuración

### Variables Disponibles

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `aws_region` | Región de AWS | `us-east-1` |
| `project_name` | Nombre del proyecto | `ec2_quarantine` |
| `vpc_cidr_block` | CIDR de la VPC | `10.0.0.0/16` |
| `subnet_cidr_block` | CIDR de la subred | `10.0.1.0/24` |
| `ami_id` | ID de la AMI | `ami-0f3f13f145e66a0a3` |
| `instance_type` | Tipo de instancia | `t2.micro` |
| `key_name` | Nombre del Key Pair | `ec2_key` |
| `notification_email` | Email para notificaciones | **Requerido** |

### Personalización de Reglas de EventBridge

El sistema actualmente se activa con hallazgos de severidad 7-8 (Alta). Para modificar esto, edita el archivo `eventbridge.tf`:

```json
"severity": [7, 8, 9] // Para incluir severidad crítica (9)
```

## 🧪 Pruebas

### Simular un Hallazgo de GuardDuty

Para probar el sistema, puedes generar tráfico sospechoso desde tu instancia EC2:

```bash
# Conectarse a la instancia
ssh -i tu-key.pem ec2-user@<ip-publica>

# Generar tráfico sospechoso (ejemplo)
nslookup suspicious-domain.com
```

**Nota**: GuardDuty puede tardar varios minutos en generar hallazgos reales.

### Verificar el Funcionamiento

1. **Logs de Lambda**: Revisa los logs en CloudWatch
2. **Estado de la Instancia**: Verifica que el grupo de seguridad cambió
3. **Notificación**: Confirma que recibiste el email de alerta

## 📁 Estructura del Proyecto

```
ec2_quarantine/
├── README.md                  # Este archivo
├── LICENSE                    # Licencia del proyecto
├── .gitignore                # Archivos ignorados por Git
├── versions.tf               # Versiones de providers
├── variables.tf              # Definición de variables
├── vpc.tf                    # Configuración de VPC y red
├── security_group.tf         # Grupos de seguridad
├── ec2.tf                    # Instancia EC2 de prueba
├── guardduty.tf             # Configuración de GuardDuty
├── eventbridge.tf           # Reglas de EventBridge
├── lambda.tf                # Función Lambda y permisos
├── sns.tf                   # Topic y suscripción SNS
├── user_data.sh             # Script de inicialización EC2
└── quarantine_lambda/
    └── index.py             # Código de la función Lambda
```

## 🔒 Consideraciones de Seguridad

- **Principio de Menor Privilegio**: Los permisos de IAM están configurados para el mínimo necesario
- **Aislamiento de Red**: Las instancias en cuarentena quedan completamente aisladas
- **Logging**: Todas las acciones se registran en CloudWatch
- **Notificaciones**: Los administradores son notificados inmediatamente

### Para Producción

- Restringe los permisos de IAM a recursos específicos (no usar `*`)
- Configura VPC Flow Logs para auditoría adicional
- Implementa rotación automática de claves
- Considera usar AWS Systems Manager para acceso sin SSH

## 🔄 Operaciones

### Restaurar una Instancia

Para sacar una instancia de cuarentena:

```bash
# Obtener el ID del grupo de seguridad original
aws ec2 describe-instances --instance-ids i-xxxxxxxxxxxxx

# Restaurar el grupo de seguridad
aws ec2 modify-instance-attribute \
  --instance-id i-xxxxxxxxxxxxx \
  --groups sg-xxxxxxxxx
```

### Monitoreo

- **CloudWatch**: Métricas de Lambda y logs detallados
- **GuardDuty Console**: Dashboard de hallazgos
- **SNS**: Historial de notificaciones

## 🧹 Limpieza

Para destruir toda la infraestructura:

```bash
terraform destroy
```

⚠️ **Advertencia**: Esto eliminará permanentemente todos los recursos creados.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una branch para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el archivo `LICENSE`.

## 📞 Soporte

Para preguntas o problemas:

- Abre un issue en el repositorio
- Revisa los logs de CloudWatch para debugging
- Consulta la documentación oficial de AWS

---

**Desarrollado con ❤️ para mejorar la seguridad en AWS**
