# Taller de Docker

Modalidad: individual. Repositorio existente: https://github.com/Gaxxenor/Taller_Docker

Autor: Gabriel Gonzalez. Correo institucional: gabrielgoso@unisabana.edu.co.

Aplicación Flask con Gunicorn, Redis persistente y balanceo con Traefik. Se conserva el código del trabajo previo, incluido el cambio local del usuario de Docker.

## Ejecutar

Desde `friendlyhello/`:

```powershell
docker build --check .
docker compose up -d --build --wait
docker compose ps
```

Abrir http://localhost:4000. Para pasar al balanceador, detener primero esta variante (sin borrar los volúmenes):

```powershell
docker compose down
docker compose -f docker-compose.traefik.yaml up -d --build --scale web=5 --wait
```

La aplicación está en http://localhost:4000 y el dashboard en http://localhost:8080/dashboard/.

## Pruebas y evidencias

Desde la raíz del taller, `./scripts/Verificar-Taller.ps1` construye las imágenes, compara el uso de caché y prueba dos despliegues aislados. Guarda las salidas reales en `evidencias/`. Usa los puertos 4001, 4002 y 8082 para evitar interferir con el trabajo anterior. Deja el balanceador de prueba ejecutándose para tomar capturas.

El script no publica imágenes, no modifica la configuración de Docker ni elimina datos existentes. Necesita acceso al motor de Docker.

## Registro

Después de iniciar sesión en Docker Hub con `docker login`, ejecutar desde `friendlyhello/`:

```powershell
docker build -t gaxxenor/friendlyhello:0.1.0 -t gaxxenor/friendlyhello:latest .
docker push gaxxenor/friendlyhello:0.1.0
docker push gaxxenor/friendlyhello:latest
$env:WEB_IMAGE = 'gaxxenor/friendlyhello:0.1.0'
docker compose -f docker-compose.registro.yaml up -d --pull always --wait
```

El archivo del ejercicio usa `image` sin `build`. El nombre anterior corresponde al usuario mostrado por Docker Desktop; la publicación aún debe verificarse. El segundo ejercicio se realiza cambiando `WEB_IMAGE` por una imagen compatible de otro autor. Como el trabajo es individual y no se proporcionó esa imagen, queda pendiente de aclaración con el docente.

## Entrega

La guía actual exige documentación en el **Wiki de GitHub**, además del código. `wiki/` contiene ocho páginas con las explicaciones, los resultados de la ejecución `20261118-223124` y cuatro capturas reales. Faltan publicar el Wiki y la imagen, e identificar el proyecto Java. No se consideran resultados de pruebas los ejemplos de comandos de este README.

Las pruebas verificaron un build sin advertencias, usuario `app`, servicios saludables, contador persistente y cinco réplicas respondiendo. La reconstrucción con dependencias en caché tomó 2,252 s, frente a 13,053 s al copiar todo antes de pip. Las veinte peticiones al balanceador alcanzaron cinco hostnames distintos, cuatro solicitudes por réplica.

El [documento de avance](https://docs.google.com/document/d/171rWU6I9vFtxM2iOolV3cW9UEaS8Ql-59sX4yEBNRaA/edit?tab=t.cs8b6y1qdnmu) tiene una pestaña nueva **Taller de Docker** con el informe y las capturas, conservando el contenido anterior.

Guía: https://github.com/CesarAVegaF312/DYAS-Docker . Autor del material: César Augusto Vega Fernández, Universidad de La Sabana. Adaptación educativa conforme a CC BY-NC-SA 4.0; partes basadas en Aula de Software Libre.
