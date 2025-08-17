# Proyecto de Remediación Automática con AWS Inspector

Este proyecto de Terraform configura un sistema de seguridad automatizado en AWS. Utiliza AWS Inspector para detectar vulnerabilidades en instancias EC2 y, a través de una regla de EventBridge y una función Lambda, aísla automáticamente cualquier instancia con una vulnerabilidad de severidad alta o crítica.

## Arquitectura

1.  **AWS Inspector:** Escanea continuamente las instancias EC2 en busca de vulnerabilidades.
2.  **EventBridge:** Una regla detecta los "Hallazgos" (Findings) de Inspector que tienen una severidad `HIGH`, `CRITICAL` o `MEDIUM`.
3.  **AWS Lambda:** Al activarse la regla, una función Lambda escrita en Python se ejecuta.
4.  **Acción de Remediación:** La función Lambda cambia el grupo de seguridad de la instancia afectada a uno de "cuarentena", que no tiene tráfico de entrada ni de salida, aislando efectivamente la instancia de la red.

## Despliegue

Sigue estos pasos para desplegar la infraestructura usando Terraform.

### 1. Inicializar Terraform

Debido a que se utiliza el proveedor `archive` para empaquetar el código de la función Lambda, es necesario inicializar el proyecto. Este comando descarga los proveedores necesarios.

```bash
terraform init -upgrade
```

### 2. Revisar y Aplicar los Cambios

Este comando te mostrará un plan de ejecución con todos los recursos de AWS que se crearán, modificarán o destruirán. Revisa cuidadosamente el plan para asegurarte de que coincide con tus expectativas.

```bash
terraform apply
```

Cuando se te solicite, escribe `yes` para confirmar y comenzar la creación de los recursos.

## Consideraciones Post-Despliegue

*   **Costos:** AWS Inspector v2 y otros servicios de AWS utilizados en este proyecto incurren en costos. Revisa la documentación oficial de precios de AWS.
*   **Proceso de "Des-cuarentena":** Este sistema automatiza el aislamiento de instancias. Para restaurar una instancia, deberás:
    1.  Remediar la vulnerabilidad (por ejemplo, aplicando parches de seguridad).
    2.  Manualmente, o a través de otro script, reasignar el grupo de seguridad original a la instancia EC2.
*   **Pruebas:** Se recomienda encarecidamente probar esta configuración en un entorno de desarrollo o pruebas antes de implementarla en producción.

## Pruebas de Funcionamiento

Para verificar que todo el sistema funciona como se espera, puedes seguir estos pasos para simular un escenario de detección y respuesta:

1.  **Desplegar la Infraestructura**: Asegúrate de haber ejecutado `terraform apply` y que todos los recursos se hayan creado correctamente. La instancia EC2 de prueba (`user_data.sh`) está diseñada para ser vulnerable.

2.  **Esperar el Escaneo de Inspector**: AWS Inspector V2 funciona de forma automática. Tras lanzar la instancia, Inspector la detectará y comenzará a escanearla. Esto puede tardar unos minutos.

3.  **Verificar el Hallazgo (Finding)**:
    *   Ve a la consola de AWS -> **Inspector**.
    *   En la sección "Findings" (Hallazgos), deberías ver un nuevo hallazgo con severidad `HIGH` o `CRITICAL` asociado a la instancia EC2 creada por Terraform.

4.  **Confirmar la Acción de Cuarentena**:
    *   El hallazgo anterior disparará la regla de EventBridge y ejecutará la función Lambda.
    *   Ve a la consola de AWS -> **EC2**.
    *   Selecciona la instancia y revisa sus **Grupos de Seguridad**. El grupo de seguridad original debería haber sido reemplazado por el grupo `quarantine-sg`, que bloquea todo el tráfico.
    *   Revisa tu correo electrónico. Deberías haber recibido una **notificación de SNS** informando sobre la acción de cuarentena.

5.  **Limpieza de Recursos**:
    *   Una vez completada la prueba, no olvides limpiar todos los recursos para evitar costos.
    *   Ejecuta el comando `terraform destroy` y confirma la operación.
