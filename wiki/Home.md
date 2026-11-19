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

## Resultados verificados

Se verificó la ejecución `20261118-223124`: construcción sin advertencias, usuario sin privilegios, servicios saludables, caché de dependencias, persistencia de Redis y cinco réplicas atendiendo veinte peticiones. Las capturas de tres hostnames y del dashboard están en `imagenes/`.

La [ejecución de GitHub Actions](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403) volvió a comprobar las aplicaciones con Docker y terminó correctamente. También construyó la aplicación Spring Boot, verificó su estado de salud y usuario sin privilegios, y publicó ambas imágenes en GHCR con etiquetas `0.1.0` y `latest`. Las páginas de los dos paquetes muestran visibilidad pública.

El [Google Docs de avance](https://docs.google.com/document/d/171rWU6I9vFtxM2iOolV3cW9UEaS8Ql-59sX4yEBNRaA/edit?tab=t.cs8b6y1qdnmu) conserva las dos capturas anteriores y tiene una pestaña nueva **Taller de Docker** con el informe y las capturas.

La [Wiki del repositorio](https://github.com/Gaxxenor/Taller_Docker/wiki) constituye la documentación oficial y esta carpeta mantiene una copia. El ejercicio de usar la imagen de un compañero queda sujeto a aclaración por la modalidad individual. La aplicación Java se creó para este taller, por lo que debe confirmarse su aceptación si el docente exige un proyecto previo del curso.

Fuente: [guía del curso](https://github.com/CesarAVegaF312/DYAS-Docker), César Augusto Vega Fernández, Universidad de La Sabana; adaptación educativa CC BY-NC-SA 4.0. Partes basadas en Aula de Software Libre.
