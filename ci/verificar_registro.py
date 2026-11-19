"""Ejercicio 1: arrancar Compose desde la imagen descargada de GHCR."""
import json
import os
import re
from pathlib import Path
from verificar import ARTIFACTS, ROOT, command, request


def main():
    image = os.environ["WEB_IMAGE"]
    compose = (ROOT / "friendlyhello/docker-compose.registro.yaml").read_text(encoding="utf-8")
    assert "build:" not in compose
    compose = compose.replace("127.0.0.1:4000:8000", "127.0.0.1:4004:8000")
    path = ARTIFACTS / "compose-imagen-publicada.yaml"
    path.write_text(compose, encoding="utf-8")
    args = ["docker", "compose", "-p", "taller-registro-ci", "-f", str(path)]
    try:
        command("registro-inicio.txt", *args, "up", "-d", "--pull", "always", "--wait", "--wait-timeout", "120")
        command("registro-ps.txt", *args, "ps")
        first = request("http://localhost:4004/")
        second = request("http://localhost:4004/")
        first_count = int(re.search(r"Visits:</b> (\d+)", first)[1])
        second_count = int(re.search(r"Visits:</b> (\d+)", second)[1])
        assert second_count == first_count + 1
        result = {"imagen": image, "build": False, "descarga": "--pull always",
                  "visita_1": first_count, "visita_2": second_count, "resultado": "correcto"}
        (ARTIFACTS / "registro-ejercicio-1.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
        (ARTIFACTS / "registro-respuesta.html").write_text(second, encoding="utf-8")
        summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary_path:
            with open(summary_path, "a", encoding="utf-8") as summary:
                summary.write("\n## Registro y ejercicio 1\n\n")
                summary.write(f"Imagen descargada de GHCR: `{image}`. Compose sin `build`, contador {first_count} → {second_count}.\n")
    finally:
        command("registro-detener.txt", *args, "down")


if __name__ == "__main__":
    main()
