# Imágenes

`hello-world/Dockerfile` usa BusyBox 1.37, copia el archivo `hello` y muestra su contenido durante el build mediante `RUN cat /hello`.

En `friendlyhello`, la base es `python:3.14-slim`. Se establece `/app` como directorio de trabajo, se copia `requirements.txt` y se instalan Flask 3.1.3, redis 8.1.0 y Gunicorn 26.2.0 antes de copiar el resto del código. Así la instalación de dependencias no se invalida por un cambio exclusivo de `app.py`.

La aplicación corre con el usuario `app` mediante Gunicorn, con dos workers y puerto 8000. `EXPOSE` documenta el puerto; la publicación en el equipo la realiza `ports` o `docker run -p`. El endpoint `/health` responde sin depender de Redis. El `HEALTHCHECK` permite que Docker detecte fallos del servidor web, aunque la base de datos esté caída.

`.dockerignore` excluye los datos de Redis, archivos de Compose, Git, bytecode y archivos `.env`; estos últimos no deben copiarse a la imagen.

## Resultados de ejecución

En la ejecución `20261118-223124`, `02-check.txt` termina con `Check complete, no warnings found.` El archivo `07-usuario.txt` contiene `uid=999(app) gid=999(app) groups=999(app)`. En `09-compose-ps.txt` y `14-balanceo-ps.txt` las instancias web y Redis aparecen como `healthy`.

La prueba sin Redis guardó una respuesta HTTP con el aviso `cannot connect to Redis, counter disabled`, en lugar de detener la aplicación. Los registros originales se conservan en la carpeta `evidencias/20261118-223124/` del paquete local.

Docker Desktop mostraba la imagen `helloapp:v1` con ID `5e231e7d1fac`, y `friendlyhello:latest` con ID `dc46946a30b4`, construidas previamente. Esto confirma que existen imágenes locales; no verifica el contenido de una nueva construcción.
