package co.edu.unisabana.gabriel;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class VisitasController {
    private final AtomicLong visitas = new AtomicLong();
    private final String nombre;
    private final String hostname;

    public VisitasController(@Value("${app.nombre}") String nombre) {
        this.nombre = nombre;
        this.hostname = System.getenv().getOrDefault("HOSTNAME", "local");
    }

    @GetMapping("/")
    public Saludo inicio() {
        return new Saludo("Hola " + nombre, hostname, visitas.incrementAndGet());
    }

    public record Saludo(String mensaje, String hostname, long visitas) {}
}
