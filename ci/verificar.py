"""Verifica las imágenes con el motor Docker del runner de GitHub Actions."""
import json
import os
from pathlib import Path
import re
import subprocess
import time
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS = ROOT / "artifacts"
ARTIFACTS.mkdir(exist_ok=True)


def command(log, *args):
    print("Ejecutando:", " ".join(args), flush=True)
    result = subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=900)
    (ARTIFACTS / log).write_text(result.stdout, encoding="utf-8")
    if result.returncode:
        print(result.stdout, flush=True)
        raise RuntimeError(f"Falló {log}, código {result.returncode}")
    return result.stdout


def request(url):
    with urlopen(url, timeout=10) as response:
        return response.read().decode("utf-8")


def wait_until(check, seconds=180):
    deadline = time.monotonic() + seconds
    last_error = None
    while time.monotonic() < deadline:
        try:
            result = check()
            if result:
                return result
        except Exception as error:
            last_error = error
        time.sleep(2)
    raise RuntimeError(f"La comprobación agotó su espera: {last_error}")


def main():
    source = "https://github.com/" + os.environ.get("GITHUB_REPOSITORY", "Gaxxenor/Taller_Docker")
    command("docker-version.txt", "docker", "version")
    command("helloapp-build.txt", "docker", "build", "--progress=plain", "-t", "helloapp:v1", "hello-world")
    for folder, image in [("friendlyhello", "friendlyhello:taller-verificado"),
                          ("proyecto-java", "taller-docker-java:0.1.0")]:
        command(f"{folder}-check.txt", "docker", "build", "--check", folder)
        command(f"{folder}-build.txt", "docker", "build", "--progress=plain", "--label",
                "org.opencontainers.image.source=" + source, "-t", image, folder)

    compose = (ROOT / "friendlyhello/docker-compose.traefik.yaml").read_text(encoding="utf-8")
    compose = compose.replace("build: .", "image: friendlyhello:taller-verificado")
    compose = compose.replace("./data:/data", "datos:/data")
    compose = compose.replace('"4000:4000"', '"127.0.0.1:4000:4000"')
    compose = compose.replace('"8080:8080"', '"127.0.0.1:8080:8080"')
    compose += "\nvolumes:\n  datos:\n"
    compose_path = ARTIFACTS / "compose-ci.yaml"
    compose_path.write_text(compose, encoding="utf-8")
    dc = ["docker", "compose", "-p", "taller-ci", "-f", str(compose_path)]
    try:
        command("compose-inicio.txt", *dc, "up", "-d", "--scale", "web=5", "--wait", "--wait-timeout", "180")
        command("compose-ps.txt", *dc, "ps")

        def five_registered_servers():
            services = json.loads(request("http://localhost:8080/api/http/services"))
            return any(service.get("name") == "web@docker" and
                       len(service.get("loadBalancer", {}).get("servers", [])) == 5
                       for service in services)

        wait_until(five_registered_servers)
        samples = []
        for number in range(1, 21):
            html = request("http://localhost:4000/")
            hostname = re.search(r"Hostname:</b> ([^<]+)", html)
            visits = re.search(r"Visits:</b> (\d+)", html)
            assert hostname and visits, html
            samples.append({"peticion": number, "hostname": hostname[1], "visitas": int(visits[1])})
        assert len({sample["hostname"] for sample in samples}) == 5, samples
        assert all(b["visitas"] == a["visitas"] + 1 for a, b in zip(samples, samples[1:])), samples
        (ARTIFACTS / "balanceo.json").write_text(json.dumps(samples, indent=2), encoding="utf-8")
        (ARTIFACTS / "traefik-servicios.json").write_text(request("http://localhost:8080/api/http/services"), encoding="utf-8")
        before = samples[-1]["visitas"]
        command("redis-reinicio.txt", *dc, "restart", "redis")

        def persisted_counter():
            html = request("http://localhost:4000/")
            match = re.search(r"Visits:</b> (\d+)", html)
            if match and int(match[1]) > before:
                return {"antes": before, "despues": int(match[1])}
            return None

        persisted = wait_until(persisted_counter)
        (ARTIFACTS / "persistencia.json").write_text(json.dumps(persisted, indent=2), encoding="utf-8")
        command("java-inicio.txt", "docker", "run", "-d", "--name", "taller-ci-java", "--memory", "512m",
                "-p", "127.0.0.1:8083:8080", "taller-docker-java:0.1.0")

        def java_healthy():
            status = command("java-health.txt", "docker", "inspect", "--format",
                             "{{.State.Health.Status}}", "taller-ci-java").strip()
            return status == "healthy"

        wait_until(java_healthy)
        first = json.loads(request("http://localhost:8083/"))
        second = json.loads(request("http://localhost:8083/"))
        assert first["mensaje"] == "Hola Gabriel", first
        assert second["visitas"] == first["visitas"] + 1, (first, second)
        assert json.loads(request("http://localhost:8083/actuator/health/readiness"))["status"] == "UP"
        identity = command("java-usuario.txt", "docker", "exec", "taller-ci-java", "id")
        assert not re.search(r"\buid=0\b", identity), identity
        (ARTIFACTS / "java-respuestas.json").write_text(json.dumps([first, second], indent=2), encoding="utf-8")
        command("java-ps.txt", "docker", "ps", "--filter", "name=taller-ci-java")
        command("java-log.txt", "docker", "logs", "taller-ci-java")
        (ARTIFACTS / "resultado.json").write_text(json.dumps({
            "estado": "correcto", "replicas": 5, "peticiones": 20,
            "redis_persistente": True, "java_saludable": True, "java_usuario_no_root": True
        }, indent=2), encoding="utf-8")
        summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary_path:
            with open(summary_path, "a", encoding="utf-8") as summary:
                summary.write("## Verificación del taller Docker\n\n")
                summary.write("Cinco réplicas, veinte peticiones y persistencia de Redis: **correcto**.\n\n")
                summary.write("## Aplicación Spring Boot en un contenedor\n\n")
                summary.write("Estado de Docker y puerto publicado:\n\n```text\n")
                summary.write((ARTIFACTS / "java-ps.txt").read_text())
                summary.write("```\n\nRespuesta HTTP real del contenedor:\n\n```json\n")
                summary.write(json.dumps([first, second], indent=2))
                summary.write("\n```\n\nUsuario del contenedor:\n\n```text\n" + identity + "```\n")
        print("Verificación Docker completada.", flush=True)
    finally:
        command("compose-logs.txt", *dc, "logs", "--no-color")
        command("compose-detener.txt", *dc, "down")
        subprocess.run(["docker", "rm", "-f", "taller-ci-java"], check=False)


if __name__ == "__main__":
    main()
