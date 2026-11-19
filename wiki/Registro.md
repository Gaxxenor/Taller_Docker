# Publicación en un registro

Docker Desktop muestra el usuario `gaxxenor`. El destino previsto es `gaxxenor/friendlyhello`, con etiquetas `0.1.0` y `latest`. Ambas deben asignarse a la misma construcción y enviarse mediante dos comandos `docker push`.

La publicación **no está verificada**. El enlace esperado, una vez publicada, es https://hub.docker.com/r/gaxxenor/friendlyhello . No se presenta como prueba de que la imagen exista actualmente.

## Ejercicio 1: usar la imagen propia

`friendlyhello/docker-compose.registro.yaml` define `image: ${WEB_IMAGE:?...}` y no contiene `build`. Se puede seleccionar la imagen con:

```powershell
$env:WEB_IMAGE = 'gaxxenor/friendlyhello:0.1.0'
docker compose -f docker-compose.registro.yaml up -d --pull always --wait
```

La opción `--pull always` permite comprobar que el despliegue usa una imagen disponible en el registro. Falta ejecutar después de publicar.

## Ejercicio 2: imagen de un compañero

El trabajo se realiza individualmente y no se proporcionó una imagen de un compañero. El mismo archivo permite cambiar `WEB_IMAGE` por una imagen compatible que sirva en el puerto 8000 y use Redis como host `redis`. Se debe consultar con el docente si acepta una imagen de otro autor como alternativa. No se declara resuelto este ejercicio.
