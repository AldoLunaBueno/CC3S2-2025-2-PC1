# Bitácora Sprint 2

## Pruebas realizadas con Bats

- DNS resolución y TTL: Todas las resoluciones exitosas para los dominios definidos en TARGETS.
- HTTP fallido (404): El script detecta correctamente el error 404 y retorna código de error.
- Robustez: Los scripts retornan código ≠ 0 en fallos controlados (dominio/URL inválida).
- Sockets abiertos con ss y conexión con nc: Se listan correctamente los sockets abiertos y se valida la conexión a puertos abiertos/cerrados.

### Resultados

- Total de pruebas ejecutadas: 8
- Pruebas exitosas: 8
- Pruebas fallidas: 0

### Observaciones

- Todos los scripts usan variables de entorno desde el archivo `.env`, lo que facilita la configuración.
- Los tests cubren casos positivos y negativos, asegurando así la robustez.
- Los reportes de pruebas se generan en la carpeta `out/` para la trazabilidad.
