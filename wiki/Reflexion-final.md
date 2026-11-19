# Reflexión final

## Imagen, contenedor y almacenamiento

Una imagen es una plantilla de capas de solo lectura con el código y las dependencias. Un contenedor es una instancia de esa imagen, con procesos en ejecución y su propia capa de escritura. Eliminar el contenedor elimina esa capa; un volumen o un montaje externo permite conservar datos independientemente del ciclo de vida del contenedor. Por eso los datos de Redis se guardan fuera de su capa de escritura.

## Orden del Dockerfile

Una modificación invalida la caché de la instrucción afectada y de las instrucciones posteriores que dependen de ella. Separar dependencias y código permite reconstruir una modificación del saludo sin reinstalar Flask, Redis y Gunicorn. Copiar todo antes de instalar dependencias hace que una edición de código fuerce trabajo adicional. Los tiempos medidos deben respaldar esta explicación; no se inventan cifras.

## Cinco réplicas y disponibilidad

Varias réplicas permiten repartir peticiones y tolerar el fallo de una instancia. No protegen frente a la caída del equipo que aloja todos los contenedores. Además, en esta configuración Redis y Traefik son instancias únicas. La alta disponibilidad exige distribuir componentes entre dominios de fallo y resolver también la disponibilidad del balanceador y del almacenamiento.

## Usuario y herramientas de compilación

Ejecutar como `root` concede más permisos dentro del contenedor a un proceso comprometido. Un usuario sin privilegios reduce el alcance de muchas acciones, aunque no sustituye el aislamiento ni corrige vulnerabilidades. Dejar Maven, compiladores y código fuente en la imagen final aumenta el tamaño y los componentes que deben mantenerse. Un build multi-stage permite distribuir solo lo necesario para ejecutar la aplicación; la imagen JRE también necesita actualizaciones y revisión de dependencias.

## Relación con el proyecto

La aplicación Java individual utiliza `APP_NAME` para configurar el saludo sin reconstruir la imagen y expone readiness mediante Actuator. La construcción multi-stage ejecuta dos pruebas HTTP antes de copiar el JAR al JRE; el contenedor resultante se verificó como `healthy` y con `uid=999(app)`. Su contador se reinicia con el proceso porque vive en memoria, a diferencia del contador compartido y persistente de Redis. Estas dos aplicaciones muestran cómo la elección de almacenamiento cambia el comportamiento al recrear o escalar contenedores.
