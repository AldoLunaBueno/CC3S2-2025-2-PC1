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

## Mejoras implementadas en Sprint 2

### Robustez y manejo de errores en scripts

- **set -euo pipefail**: Implementado en `check_dns.sh` y `check_http.sh` para terminación inmediata en errores.
- **Funciones trap y cleanup**: Manejo automático de códigos de salida y limpieza de recursos.
- **Validación de argumentos**: Verificación estricta de parámetros de entrada con mensajes de ayuda.

### Uso de toolkit Unix para enriquecer validaciones

- **grep**: Filtrado de registros DNS por dominio específico.
- **sed**: Limpieza de URLs y eliminación de espacios en blanco.
- **awk**: Formateo avanzado de salida con TTL y alineación de columnas.
- **cut**: Extracción de componentes de URL (dominio sin path).
- **wc**: Conteo de registros DNS encontrados para validación.

### Funciones Bash estructuradas

- `resolve_dns()`: Función principal para resolución DNS con parámetros locales.
- `validate_url()`: Validación de formato de URL con limpieza automática.
- `check_get()` y `check_post()`: Funciones especializadas para métodos HTTP.

### Códigos de salida documentados

- **Código 0**: Operación exitosa
- **Código 1**: Error en resolución DNS/HTTP o validación  
- **Código 130**: Interrupción por usuario (Ctrl+C)
- **Documentación completa**: Creado `docs/contrato-salidas.md` con ejemplos.