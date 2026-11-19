# Aplicación Java para el taller

Aplicación individual creada para desarrollar la Parte 4 porque no se disponía de un proyecto Spring Boot previo del curso. No se presenta como un proyecto anterior del equipo; si el docente exige ese proyecto, se debe confirmar que acepta esta aplicación.

Java 21 y Spring Boot 4.1.2. La ruta `/` devuelve JSON con el saludo, el hostname y un contador en memoria. `APP_NAME` permite cambiar el nombre del saludo. El contador se reinicia al recrear esta aplicación: no usa una base de datos. La persistencia y el contador compartido se desarrollan en la aplicación Flask/Redis del taller.

`/actuator/health/readiness` comprueba que el servidor está listo. No se requieren servicios externos.

## Construir y ejecutar

```powershell
docker build --check .
docker compose up -d --build --wait --wait-timeout 180
docker compose ps
```

Abrir http://localhost:8083 y http://localhost:8083/actuator/health/readiness.

## Construcción multi-stage

La primera etapa contiene Maven y JDK, instala las dependencias antes de copiar el código y ejecuta `mvn verify`, incluyendo dos pruebas HTTP. La segunda etapa usa únicamente el JRE, copia `target/app.jar` y ejecuta con el usuario `app`. El Dockerfile fija las versiones de las imágenes, incluye comprobación de salud y limita la memoria de la JVM en relación con el límite del contenedor.

Con Maven y Java 21 locales se puede ejecutar `mvn verify`. Las pruebas comprueban el nombre por configuración, el aumento del contador y la respuesta del endpoint de readiness. La prueba local no sustituye la ejecución del contenedor.

Documentación de compatibilidad: https://docs.spring.io/spring-boot/system-requirements.html
