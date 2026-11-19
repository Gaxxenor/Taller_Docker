# Proyecto Java

Se desarrolló una aplicación Spring Boot individual en [`proyecto-java/`](https://github.com/Gaxxenor/Taller_Docker/tree/main/proyecto-java), porque no se disponía de un proyecto Spring Boot previo. Esta aplicación se creó para el taller; no se presenta como un proyecto anterior del curso. Si el docente exige usar dicho proyecto, debe confirmar que acepta esta alternativa.

La aplicación usa Java 21 y Spring Boot 4.1.2. `/` responde con JSON que contiene el saludo configurable mediante `APP_NAME`, el hostname y un contador en memoria. `/actuator/health/readiness` permite comprobar que el servidor está listo. No necesita base de datos: la persistencia se demuestra por separado en Flask/Redis.

## Dockerfile multi-stage

La primera etapa utiliza `maven:3.9.16-eclipse-temurin-21-noble`, instala las dependencias antes de copiar el código y ejecuta `mvn verify`, incluyendo dos pruebas HTTP. La etapa final parte de `eclipse-temurin:21.0.12.1_1-jre-noble` y copia únicamente `target/app.jar`. Maven y el código fuente no llegan a esa imagen.

El usuario final es `app`; `HEALTHCHECK` consulta el endpoint de readiness. `.dockerignore` excluye los archivos `.env`, Git y los resultados locales de compilación. Compose publica `127.0.0.1:8083:8080` y limita la memoria del contenedor a 512 MB; la JVM usa como máximo el 75 % para el heap.

## Verificación real

`mvn verify` terminó correctamente tanto de forma local como durante la construcción Docker de [GitHub Actions](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403): **2 pruebas, 0 fallos, 0 errores y 0 omitidas**. Las pruebas comprobaron el nombre configurado, el aumento del contador y la respuesta de readiness.

En el runner, el contenedor `taller-ci-java` apareció como `healthy`, con ID `823f64b5a365`. La ejecución de `id` devolvió:

```text
uid=999(app) gid=999(app) groups=999(app)
```

Dos consultas HTTP al contenedor devolvieron:

```json
[
  {"mensaje": "Hola Gabriel", "hostname": "823f64b5a365", "visitas": 1},
  {"mensaje": "Hola Gabriel", "hostname": "823f64b5a365", "visitas": 2}
]
```

Los registros de [docker ps](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/java-ps.txt), [usuario](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/java-usuario.txt), [respuestas HTTP](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/java-respuestas.json) y [construcción con pruebas](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/proyecto-java-build.txt) se conservan en el repositorio. La imagen se publicó en `ghcr.io/gaxxenor/taller-docker-java`, con etiquetas `0.1.0` y `latest`.

Captura del resumen de GitHub Actions con el estado real de Docker y las respuestas HTTP del contenedor:

![Contenedor Java saludable y respuestas HTTP](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/java-ci.jpg)
