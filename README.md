# Taller de Docker

Trabajo individual de **Gabriel Gonzalez**, **gabrielgoso@unisabana.edu.co**.

Aplicación Flask con Redis persistente y cinco réplicas detrás de Traefik, más una aplicación Spring Boot individual con construcción multi-stage. Las imágenes se verifican y publican mediante GitHub Actions.

- [Wiki de la entrega](https://github.com/Gaxxenor/Taller_Docker/wiki)
- [Ejecución Docker verificada](https://github.com/Gaxxenor/Taller_Docker/actions/runs/44455711403)
- [Documento de avance](https://docs.google.com/document/d/171rWU6I9vFtxM2iOolV3cW9UEaS8Ql-59sX4yEBNRaA/edit?tab=t.cs8b6y1qdnmu)
- [Imagen Flask](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/friendlyhello)
- [Imagen Java](https://github.com/Gaxxenor/Taller_Docker/pkgs/container/taller-docker-java)

## Resultados

Las pruebas comprobaron la construcción sin advertencias, el usuario `app`, servicios saludables, persistencia de Redis y cinco hostnames distintos en veinte peticiones. La reconstrucción local con dependencias en caché tomó **2,252 s**, frente a **13,053 s** copiando todo antes de instalar las dependencias.

La aplicación Java pasó **2 pruebas HTTP, sin fallos ni errores**, generó un JAR ejecutable y corrió en un contenedor saludable y sin privilegios. Las dos imágenes se publicaron en GHCR con etiquetas `0.1.0` y `latest`; ambas aparecen como públicas.

Los registros y capturas relevantes están en `wiki/`. Los logs completos de cada ejecución de CI se pueden descargar desde sus artefactos en GitHub Actions.

La carpeta [`entrega/`](entrega/README.md) reúne el informe, las seis capturas enlazadas y una copia permanente de todos los registros de las ejecuciones exitosas local y de CI. Incluye el estado frente a los requisitos y las dos salvedades de la modalidad individual.

## Ejecutar Flask y Redis

Desde `friendlyhello/`:

```powershell
docker build --check .
docker compose up -d --build --wait
docker compose ps
```

Abrir http://localhost:4000. Para pasar al balanceador, detener primero esta variante sin eliminar los datos:

```powershell
docker compose down
docker compose -f docker-compose.traefik.yaml up -d --build --scale web=5 --wait
```

La aplicación está en http://localhost:4000 y el dashboard en http://localhost:8080/dashboard/.

## Usar la imagen publicada

Desde `friendlyhello/`, después de detener la variante anterior para liberar el puerto 4000:

```powershell
$env:WEB_IMAGE = 'ghcr.io/gaxxenor/friendlyhello:0.1.0'
docker compose -f docker-compose.registro.yaml up -d --pull always --wait
```

Este archivo usa `image` sin `build`. El workflow comprueba también el despliegue desde el registro. El segundo ejercicio de la guía pide usar la imagen de un compañero: como el trabajo es individual y no se proporcionó esa imagen, se documenta esta limitación en la Wiki para aclararla con el docente.

## Ejecutar Java

Desde `proyecto-java/`:

```powershell
docker compose up -d --build --wait --wait-timeout 180
```

Abrir http://localhost:8083. También puede descargarse directamente:

```powershell
docker run --rm -p 127.0.0.1:8083:8080 ghcr.io/gaxxenor/taller-docker-java:0.1.0
```

La aplicación se creó para la Parte 4 porque no había un proyecto Spring Boot previo. Si el docente exige utilizar el proyecto anterior del curso, debe confirmar que acepta esta alternativa.

## Repetir las pruebas

`./scripts/Verificar-Taller.ps1` recoge los resultados locales sin afectar los datos previos: utiliza los puertos 4001, 4002 y 8082 y deja el balanceador ejecutándose para tomar capturas. `ci/verificar.py` realiza la comprobación de las imágenes en GitHub Actions; `ci/verificar_registro.py` prueba Compose desde la imagen publicada. El script `Publicar-Imagen.ps1` se conserva como alternativa para publicar en Docker Hub, pero el registro utilizado en esta entrega es **GHCR**.

Material base: [César Augusto Vega Fernández, Universidad de La Sabana](https://github.com/CesarAVegaF312/DYAS-Docker). Adaptación educativa CC BY-NC-SA 4.0; partes basadas en Aula de Software Libre.
