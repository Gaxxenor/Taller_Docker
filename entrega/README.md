# Entrega del taller de Docker

**Gabriel Gonzalez** — **gabrielgoso@unisabana.edu.co** — trabajo individual.

## Enlaces de entrega

- [Código del repositorio](https://github.com/Gaxxenor/Taller_Docker)
- [Wiki oficial con ocho secciones](https://github.com/Gaxxenor/Taller_Docker/wiki)
- [Informe con seis capturas verificadas](Informe-Docker.md)
- [Pruebas de Docker aprobadas](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403)
- [Imagen Flask pública](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/friendlyhello)
- [Imagen Java pública](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/taller-docker-java)

## Evidencias conservadas

`registros-locales/` contiene los archivos de la ejecución exitosa `20261118-223124`: construcción, comprobación de usuario, caché, tiempos, Compose, persistencia de Redis y balanceo. Se omiten los contextos de construcción temporales; sus resultados están en los logs.

`registros-ci/` contiene todos los archivos del artefacto de la ejecución exitosa `44455711403`: construcción de las imágenes, dos pruebas HTTP de Java, estado de salud y usuario del contenedor, veinte solicitudes al balanceador, publicación y descarga de GHCR, y despliegue de Compose sin `build` desde la imagen publicada.

Las capturas están en [`wiki/imagenes/`](../wiki/imagenes). Los registros se copian aquí para conservarlos más allá del plazo de retención de los artefactos de Actions; solo se normalizan los espacios al final de línea de las copias de texto.

## Estado frente a la guía

| Componente | Estado |
| --- | --- |
| Repositorio, estructura e integrante | Publicados |
| Dockerfile, usuario sin privilegios y salud | Verificados |
| Caché de capas y comparación de tiempos | Verificadas |
| Compose, Redis y persistencia | Verificados |
| Cinco réplicas y dashboard de Traefik | Verificados |
| Publicación con versión y `latest` | Dos imágenes públicas en GHCR |
| Ejercicio de usar la imagen propia sin `build` | Verificado desde el registro |
| Wiki y reflexión técnica | Publicadas |
| Aplicación Java con Dockerfile multi-stage | Aplicación individual creada y probada para el taller |
| Ejercicio de usar la imagen de un compañero | Pendiente de aclaración con el docente por modalidad individual |

La aplicación Java se creó porque no se disponía de un proyecto Spring Boot previo del curso. Si el docente exige utilizar dicho proyecto, se debe confirmar que acepta esta alternativa. La documentación distingue estos puntos de los resultados ya comprobados.
