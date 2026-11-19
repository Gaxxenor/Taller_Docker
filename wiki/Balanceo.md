# Balanceo con Traefik

El servicio web deja de publicar puertos. Traefik recibe las peticiones y descubre las réplicas mediante las etiquetas de los contenedores. La regla ``Host(`localhost`)`` requiere abrir la aplicación con el nombre `localhost`; usar la dirección IP directamente no coincide con esa regla.

El puerto interno del servicio web es 8000. Cada respuesta incluye el hostname del contenedor que la atendió, mientras todas las instancias comparten el contador de Redis. El archivo no fija `container_name`, lo que permite escalar `web=5`.

El dashboard sin autenticación y el socket de Docker corresponden a una demostración local. El script publica sus puertos exclusivamente en `127.0.0.1`, en 4002 y 8082, y deja el despliegue disponible para las capturas.

## Resultados de ejecución

En la ejecución `20261118-223124`, `14-balanceo-ps.txt` mostró cinco instancias web y Redis en estado `healthy`. Las veinte peticiones de `balanceo.csv` fueron atendidas por cinco hostnames distintos; cada uno recibió cuatro peticiones. El contador avanzó de 4 a 23.

| Hostname | Peticiones |
| --- | --- |
| `5022d6112a86` | 4 |
| `1c4a4125e977` | 4 |
| `b3d9d4dec7d4` | 4 |
| `106e20585dd7` | 4 |
| `ed2f80bbdc82` | 4 |

Capturas posteriores en el navegador, con tres réplicas diferentes y el contador continuando:

![Réplica con contador](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/replica-1.jpg)

![Segunda réplica con contador](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/replica-2.jpg)

![Tercera réplica con contador](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/replica-3.jpg)

El dashboard de Traefik 3.7.16 mostró tres routers y cuatro servicios habilitados, sin advertencias ni errores. También se guardó la respuesta real de `/api/http/services` en `traefik-servicios.json`.

![Dashboard de Traefik](https://raw.githubusercontent.com/wiki/Gaxxenor/Taller_Docker/imagenes/dashboard.jpg)
