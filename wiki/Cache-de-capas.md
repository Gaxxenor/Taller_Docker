# Caché de capas

El Dockerfile copia primero `requirements.txt` e instala las dependencias. Después copia `app.py`. Al cambiar únicamente el saludo, las capas anteriores a la copia del código siguen siendo reutilizables: `RUN pip install` debe aparecer como `CACHED`.

Si `COPY . .` se coloca antes de `RUN pip install`, un cambio en el código invalida la capa que contiene toda la aplicación y la instalación posterior debe volver a ejecutarse. El coste se nota especialmente con dependencias grandes o una red lenta.

El script prepara dos contextos aislados, construye cada uno una vez, modifica el mismo saludo y mide una nueva construcción con `--progress=plain`. No modifica el código original para esta comparación. Guarda `tiempos.csv` y los logs `05-cambio-*.txt`.

## Resultados medidos

Los tiempos provienen de `tiempos.csv` de la ejecución `20261118-223124`. Los logs `05-cambio-optimizado.txt` y `05-cambio-copy-antes-de-pip.txt` muestran respectivamente la reutilización y la nueva ejecución de pip. Las descargas y la caché de BuildKit pueden afectar la comparación; una medición local ilustra este caso y no representa un benchmark general.

| Estrategia | Tiempo de reconstrucción | Paso pip |
| --- | --- | --- |
| Dependencias antes del código | 2,252 s | `CACHED` |
| Todo el código antes de pip | 13,053 s | Nueva ejecución de pip: 9,8 s |

La reconstrucción optimizada tardó 10,801 segundos menos; la otra estrategia tomó aproximadamente 5,8 veces ese tiempo.

Extracto del registro optimizado:

```text
#8 [4/6] RUN pip install --no-cache-dir -r requirements.txt
#8 CACHED
```

Extracto del orden alternativo:

```text
#8 [4/6] RUN pip install --no-cache-dir -r requirements.txt
#8 DONE 9.8s
```
