# Contrato de Códigos de Salida

Este documento define los códigos de salida utilizados por los scripts del proyecto para garantizar comportamiento consistente y facilitar la integración con sistemas de automatización.

## Convenciones Generales

- **Código 0**: Operación exitosa
- **Código ≠ 0**: Error o fallo en la operación
- **Código 130**: Interrupción por usuario (Ctrl+C)

## Scripts del Sistema

### check_dns.sh

Valida resoluciones DNS utilizando `dig` con dominios definidos en variables de entorno.

#### Códigos de Salida

| Código | Descripción | Escenario |
|--------|-------------|-----------|
| 0 | Éxito | Todas las resoluciones DNS completadas exitosamente |
| 1 | Error genérico | Archivo `.env` no encontrado, tipo de registro no soportado, argumentos incorrectos |
| 1 | Error de resolución | No se encontraron registros para uno o más dominios |
| 1 | Error de red | Fallo en consulta DNS (timeout, servidor no disponible) |
| 130 | Interrupción | Usuario interrumpe con Ctrl+C |

#### Ejemplos de Uso

```bash
# Caso exitoso
./check_dns.sh A
echo $?  # Retorna 0

# Caso de error - dominio inexistente
TARGETS="dominio-inexistente-xyz123.com" ./check_dns.sh
echo $?  # Retorna 1
```

### check_http.sh

Valida peticiones HTTP utilizando `curl` con URLs definidas en variables de entorno.

#### Códigos de Salida

| Código | Descripción | Escenario |
|--------|-------------|-----------|
| 0 | Éxito | Todas las peticiones HTTP completadas exitosamente |
| 1 | Error genérico | Archivo `.env` no encontrado, método no soportado, argumentos incorrectos |
| 1 | Error de validación | URL malformada (no comienza con http:// o https://) |
| 1 | Error HTTP | Códigos 4xx, 5xx o fallos de conexión |
| 130 | Interrupción | Usuario interrumpe con Ctrl+C |

#### Ejemplos de Uso

```bash
# Caso exitoso
./check_http.sh GET
echo $?  # Retorna 0

# Caso de error - URL inválida
CONFIG_URL=" " ./check_http.sh GET
echo $?  # Retorna 1
```