package co.edu.unisabana.gabriel;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "app.nombre=Prueba")
class AplicacionTest {
    @Value("${local.server.port}")
    int puerto;

    private HttpResponse<String> consultar(String ruta) throws Exception {
        return HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build().send(
                HttpRequest.newBuilder(URI.create("http://localhost:" + puerto + ruta))
                        .timeout(Duration.ofSeconds(10)).GET().build(),
                HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void respondeConNombreConfiguradoYContadorIncremental() throws Exception {
        var primera = consultar("/");
        var segunda = consultar("/");
        assertEquals(200, primera.statusCode());
        assertEquals(200, segunda.statusCode());
        assertTrue(primera.body().contains("Hola Prueba"));
        assertTrue(primera.body().contains("\"visitas\":1"));
        assertTrue(segunda.body().contains("\"visitas\":2"));
    }

    @Test
    void exponeReadinessSinServiciosExternos() throws Exception {
        var respuesta = consultar("/actuator/health/readiness");
        assertEquals(200, respuesta.statusCode());
        assertTrue(respuesta.body().contains("\"status\":\"UP\""));
    }
}
