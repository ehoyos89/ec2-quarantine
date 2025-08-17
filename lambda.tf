# Este recurso empaqueta el código de la función Lambda en un archivo .zip para su despliegue.
# Terraform se encarga de crear el archivo zip a partir del directorio especificado.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/quarantine_lambda" # Directorio que contiene el código Python.
  output_path = "${path.module}/quarantine_lambda.zip" # Ruta donde se guardará el .zip resultante.
}

# Rol de IAM que la función Lambda asumirá al ejecutarse.
# Le concede a Lambda el permiso para actuar en nombre de otros servicios de AWS.
resource "aws_iam_role" "lambda_exec_role" {
  name = "inspector_quarantine_lambda_role"

  # Política de confianza: especifica qué entidades pueden asumir este rol (en este caso, el servicio Lambda).
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Política de IAM que define los permisos específicos que tendrá la función Lambda.
resource "aws_iam_policy" "lambda_permissions" {
  name        = "inspector_quarantine_lambda_policy"
  description = "Permissions for Inspector Quarantine Lambda"

  # El documento de la política en formato JSON.
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Permisos para describir y modificar instancias EC2 (para aplicar la cuarentena).
        Action = [
          "ec2:DescribeInstances",
          "ec2:ModifyInstanceAttribute"
        ],
        Effect   = "Allow",
        Resource = "*" # Para simplicidad, se aplica a todos los recursos. En un entorno productivo, debería restringirse.
      },
      {
        # Permisos para escribir logs en CloudWatch.
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # Permiso para publicar mensajes en el tema de SNS.
        Action = [
          "sns:Publish"
        ],
        Effect   = "Allow",
        Resource = aws_sns_topic.quarantine_notifications.arn # Apunta al ARN del tema de SNS creado en sns.tf.
      }
    ]
  })
}

# Asocia la política de permisos (lambda_permissions) con el rol de ejecución (lambda_exec_role).
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

# Define la función Lambda en sí.
resource "aws_lambda_function" "quarantine_instance" {
  function_name    = "quarantine-instance-from-inspector"
  filename         = data.archive_file.lambda_zip.output_path # El archivo .zip con el código.
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 # Hash del archivo para detectar cambios.
  role             = aws_iam_role.lambda_exec_role.arn # El rol de IAM que usará la función.
  handler          = "index.handler" # El punto de entrada: archivo 'index', función 'handler'.
  runtime          = "python3.9"

  # Define las variables de entorno que se pasarán a la función Lambda.
  environment {
    variables = {
      QUARANTINE_SG_ID = aws_security_group.quarantine.id, # Pasa el ID del SG de cuarentena.
      SNS_TOPIC_ARN    = aws_sns_topic.quarantine_notifications.arn # Pasa el ARN del tema de SNS.
    }
  }

  # Asegura que el rol y la política estén completamente adjuntos antes de crear la función.
  depends_on = [
    aws_iam_role_policy_attachment.lambda_attach
  ]
}
