#!/bin/bash
# Este script se ejecuta automáticamente la primera vez que una instancia EC2 se inicia.
# Instala un servidor web y muestra información de la propia instancia.

# Actualiza los paquetes e instala el servidor web Apache (httpd) y curl.
yum update -y
yum install -y httpd curl

# Inicia y habilita el servicio Apache.
service httpd start
systemctl enable httpd

# --- Obtener Metadatos de la Instancia EC2 ---
# Se utiliza el servicio de metadatos de EC2, accesible en una IP local especial.
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# --- Crear la página HTML ---
# Se utiliza un "Here Document" (cat <<EOF) para crear el archivo HTML de forma legible.
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance Information</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f2f5; color: #333; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .container { padding: 30px; background-color: #fff; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); max-width: 700px; text-align: center; }
        h1 { color: #d84315; }
        p { font-size: 1.2em; line-height: 1.6; }
        strong { color: #1a237e; }
    </style>
</head>
<body>
    <div class="container">
        <h1>EC2 Instance Information</h1>
        <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
        <p><strong>Instance Type:</strong> $INSTANCE_TYPE</p>
        <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
        <p><strong>Public IP:</strong> $PUBLIC_IP</p>
    </div>
</body>
</html>
EOF
