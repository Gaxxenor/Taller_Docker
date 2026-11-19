# Taller de Docker

Trabajo individual de **Gabriel Gonzalez**. Correo institucional: **gabrielgoso@unisabana.edu.co**. Cuenta del repositorio: **Gaxxenor**.

## Propósito

Construir imágenes propias, explicar la caché de capas y ejecutar una aplicación Flask con Redis. Escalar cinco instancias detrás de Traefik y distribuir la imagen mediante un registro. Aplicar las mismas prácticas al proyecto Java.

## Secciones

- [Imágenes](Imagenes)
- [Caché de capas](Cache-de-capas)
- [Compose](Compose)
- [Balanceo](Balanceo)
- [Registro](Registro)
- [Proyecto](Proyecto)
- [Reflexión final](Reflexion-final)

## Estado de este borrador

Se verificó la ejecución `20261118-223124`: construcción sin advertencias, usuario sin privilegios, servicios saludables, caché de dependencias, persistencia de Redis y cinco réplicas atendiendo veinte peticiones. Las capturas de tres hostnames y del dashboard están en `imagenes/`.

El [Google Docs original](https://docs.google.com/document/d/171rWU6I9vFtxM2iOolV3cW9UEaS8Ql-59sX4yEBNRaA/edit?tab=t.cs8b6y1qdnmu) conserva las dos capturas anteriores y tiene una pestaña nueva **Taller de Docker** con el informe y cuatro capturas de esta ejecución. Faltan publicar la imagen y el Wiki e identificar el proyecto Java.

La guía exige el **Wiki del repositorio** como entrega oficial. Esta carpeta contiene contenido preparado para ese Wiki; su existencia local no equivale a haberlo publicado.

Fuente: [guía del curso](https://github.com/CesarAVegaF312/DYAS-Docker), César Augusto Vega Fernández, Universidad de La Sabana; adaptación educativa CC BY-NC-SA 4.0. Partes basadas en Aula de Software Libre.
