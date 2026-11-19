# Proyecto Java

La Parte 4 de la guía actual requiere contenerizar el proyecto Spring Boot del curso. El trabajo individual no elimina por sí mismo ese requisito.

Todavía falta identificar el repositorio del proyecto. Los dos talleres Maven localizados en Documents son ejercicios de patrones con Java 8; sus `pom.xml` no declaran Spring Boot y no constituyen evidencia del proyecto solicitado.

Cuando se identifique el proyecto, el Dockerfile debe compilar con Maven en una etapa y copiar únicamente el JAR ejecutable a una imagen JRE en la etapa final. Debe ejecutar con usuario sin privilegios, excluir `.env`, Git y `target/` del contexto y verificar un endpoint de salud real. Si existe base de datos, la conexión debe usar el nombre de servicio de Compose, no `localhost`.

Pendientes: adaptar el Dockerfile a la versión real de Java y al JAR del proyecto, construirlo, ejecutar la aplicación con sus dependencias y adjuntar una captura. No se entrega una plantilla genérica como si fuera una implementación probada.
