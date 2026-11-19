# Compose y Redis

Compose crea una red donde la aplicación resuelve `redis` por el nombre del servicio. El contador usa `INCR counter`, una operación atómica de Redis que permite compartir el total de visitas entre los workers y las réplicas.

`depends_on` con `service_healthy` espera la respuesta satisfactoria de `redis-cli ping` antes de iniciar la aplicación. No garantiza que Redis permanezca disponible después: el código captura `RedisError` y muestra que el contador está deshabilitado si falla la conexión.

Redis usa AOF con `--appendonly yes` y un montaje `./data:/data`. Al recrear el contenedor, los archivos del host siguen presentes. El script de verificación usa un volumen con nombre aislado para no alterar los datos previos del taller y comprueba que el contador aumente después de un ciclo `down`/`up`.

## Resultados de ejecución

En `20261118-223124`, los dos servicios aparecieron como `healthy`. Las respuestas guardadas en `redis-visita-1.html` y `redis-visita-2.html` devolvieron visitas **1** y **2**, con hostname `11b3abf1a2a9`. Tras `down` y `up`, `redis-persistencia.html` devolvió visitas **3** con hostname `eb16ea2818ac`: el proceso cambió y el contador se conservó.

Las siguientes capturas del despliegue balanceado muestran el mismo contador compartido avanzando entre instancias:

![Contador compartido en una réplica](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/replica-1.jpg)

![Contador compartido en otra réplica](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/replica-2.jpg)
