# Publicación en un registro

Se utilizó **GitHub Container Registry (GHCR)**, alternativa contemplada en la Parte 3 de la guía. El workflow autentica la publicación con su `GITHUB_TOKEN` temporal y permiso `packages: write`.

| Aplicación | Imagen | Etiquetas |
| --- | --- | --- |
| Flask y Redis | `ghcr.io/gaxxenor/friendlyhello` | `0.1.0`, `latest` |
| Spring Boot | `ghcr.io/gaxxenor/taller-docker-java` | `0.1.0`, `latest` |

Las páginas de [Flask](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/friendlyhello) y [Java](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/taller-docker-java) muestran ambas etiquetas y visibilidad **Public**. La [primera ejecución verificada](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403) publicó las dos imágenes y volvió a descargarlas correctamente con `docker pull`.

## Ejercicio 1 usar la imagen propia

`friendlyhello/docker-compose.registro.yaml` define `image: ${WEB_IMAGE:?...}` y no contiene `build`:

```powershell
$env:WEB_IMAGE = 'ghcr.io/gaxxenor/friendlyhello:0.1.0'
docker compose -f docker-compose.registro.yaml up -d --pull always --wait
```

La [ejecución 44455711403](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403) descargó esta imagen mediante `--pull always`, levantó el archivo de Compose sin `build` y mostró ambos servicios como `healthy`. Dos consultas incrementaron el contador de **1** a **2**. Se conservaron el [resultado del ejercicio](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/registro-ejercicio-1.json), el [estado de los servicios](https://github.com/Gaxxenor/Taller_Docker/blob/main/wiki/registros-ci/registro-ps.txt) y la respuesta HTTP entre los artefactos de la ejecución.

![Imagen pública con ambas etiquetas](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/registro.jpg)

## Ejercicio 2 imagen de un compañero

El trabajo se realiza individualmente y no se proporcionó una imagen de un compañero. El mismo archivo permite cambiar `WEB_IMAGE` por una imagen compatible que sirva en el puerto 8000 y use Redis como host `redis`. Se debe aclarar con el docente si acepta una imagen de otro autor como alternativa. No se declara resuelto este ejercicio ni se inventa un compañero.
