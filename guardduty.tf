# Este recurso representa el detector de GuardDuty para la cuenta de AWS en la región actual.
# GuardDuty debe estar habilitado para que pueda generar los hallazgos que desencadenan la cuarentena.
resource "aws_guardduty_detector" "main" {
  # Habilita el detector. Si se establece en 'false', GuardDuty se suspende.
  enable = true

  tags = {
    Name = "GuardDuty-Detector-Principal"
  }
}
