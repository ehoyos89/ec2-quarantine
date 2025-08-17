# Define un tema (topic) de SNS (Simple Notification Service).
# Un tema es un canal de comunicación al que se pueden enviar mensajes (notificaciones).
resource "aws_sns_topic" "quarantine_notifications" {
  name = "quarantine-notifications"
}

# Crea una suscripción al tema de SNS definido arriba.
# Una suscripción define un "punto final" (endpoint) que recibirá los mensajes publicados en el tema.
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.quarantine_notifications.arn # Se suscribe al tema de notificaciones de cuarentena.
  protocol  = "email" # El protocolo de la suscripción es el correo electrónico.
  endpoint  = var.notification_email # La dirección de correo a la que se enviarán las notificaciones. Se define en variables.tf.
}
