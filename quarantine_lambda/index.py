import boto3
import os
import logging
import json

# --- Configuración Inicial ---

# Configurar el sistema de logging para registrar información del proceso.
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Inicializar los clientes de AWS para EC2 y SNS.
ec2 = boto3.client('ec2')
sns = boto3.client('sns')

# Obtener variables de entorno pasadas desde la configuración de Terraform.
# QUARANTINE_SG_ID: El ID del grupo de seguridad que aísla la instancia.
# SNS_TOPIC_ARN: El ARN del tema de SNS para enviar notificaciones.
quarantine_sg_id = os.environ['QUARANTINE_SG_ID']
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def handler(event, context):
    """
    Función principal de la Lambda que se ejecuta cada vez que EventBridge la invoca.
    
    Args:
        event (dict): El objeto de evento que contiene los detalles del hallazgo de GuardDuty.
        context (object): El objeto de contexto de ejecución de Lambda (no se usa en este caso).
    """
    logger.info("Evento recibido de GuardDuty: %s", event)

    # --- Extracción de Datos del Evento ---

    # Extraer el ID de la instancia EC2 del objeto de evento de GuardDuty.
    # La ruta 'detail.resource.instanceDetails.instanceId' es específica de los hallazgos de GuardDuty para EC2.
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']
    
    if not instance_id:
        logger.error("No se pudo encontrar el ID de la instancia en el evento de GuardDuty.")
        return

    logger.info(f"Instancia {instance_id} reportada. Aplicando grupo de seguridad de cuarentena: {quarantine_sg_id}")

    try:
        # --- Lógica de Cuarentena ---

        # Se modifica el atributo de la instancia para reemplazar sus grupos de seguridad actuales
        # por el grupo de seguridad de cuarentena. Esto la aísla de la red.
        ec2.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[quarantine_sg_id]  # Se asigna únicamente el SG de cuarentena.
        )
        logger.info(f"Instancia {instance_id} ha sido puesta en cuarentena exitosamente.")

        # --- Notificación ---

        # Preparar un mensaje detallado para la notificación.
        message = {
            'message': f"La instancia EC2 {instance_id} ha sido puesta en cuarentena debido a un hallazgo de GuardDuty.",
            'instance_id': instance_id,
            'quarantine_sg_id': quarantine_sg_id,
            'guardduty_finding': event  # Incluir el evento completo para análisis forense.
        }
        
        # Publicar el mensaje en el tema de SNS especificado.
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message, indent=4),
            Subject=f"Alerta de Cuarentena de EC2: {instance_id}"
        )
        logger.info(f"Notificación enviada a SNS para la instancia {instance_id}.")

    except Exception as e:
        # Si ocurre cualquier error, se registra y se relanza la excepción para que la invocación de Lambda falle.
        logger.error(f"Error en el proceso de cuarentena o notificación para la instancia {instance_id}: {str(e)}")
        raise e

    return {
        'statusCode': 200,
        'body': f"Instancia {instance_id} en cuarentena y notificación enviada."
    }
