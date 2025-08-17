# Define una regla de EventBridge (anteriormente CloudWatch Events) que actúa como un filtro de eventos.
resource "aws_cloudwatch_event_rule" "guardduty_finding_rule" {
  name        = "capture-guardduty-ec2-findings"
  description = "Capture GuardDuty findings related to EC2 instances"

  # El patrón de evento define qué eventos activarán esta regla.
  event_pattern = jsonencode({
    "source": ["aws.guardduty"], # Solo eventos originados por GuardDuty.
    "detail-type": ["GuardDuty Finding"], # Específicamente, los que son hallazgos.
    "detail": {
      "resource": {
        "resourceType": ["Instance"] # El recurso afectado debe ser una instancia EC2.
      },
      # La severidad del hallazgo debe ser Alta (7.0-8.9) o Crítica (9.0-10.0).
      # GuardDuty usa valores numéricos para la severidad.
      "severity": [7, 8]
    }
  })
}

# Define el "objetivo" (target) de la regla de EventBridge.
# Cuando un evento coincide con la regla, se envía a este objetivo.
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_finding_rule.name # Asocia este objetivo con la regla definida arriba.
  target_id = "QuarantineLambdaTarget"
  arn       = aws_lambda_function.quarantine_instance.arn # El objetivo es la función Lambda de cuarentena.
}

# Otorga permiso a EventBridge para invocar la función Lambda.
# Sin esto, la regla se activaría pero no podría ejecutar la función.
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quarantine_instance.function_name
  principal     = "events.amazonaws.com" # El principal que puede invocar es el servicio de EventBridge.
  source_arn    = aws_cloudwatch_event_rule.guardduty_finding_rule.arn # El permiso se concede solo para invocaciones originadas por nuestra regla.
}
