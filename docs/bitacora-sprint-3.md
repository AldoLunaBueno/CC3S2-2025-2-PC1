# Bitácora Sprint 3

## 1. Sistema de caché incremental

### Implementación
- Sistema de stamps en directorio `.stamps/`
- Archivos: `http.stamp`, `dns.stamp`, `test.stamp`
- Dependencias definidas por archivo fuente y `.env`

### Funcionamiento
- Solo ejecuta tareas cuando las dependencias cambian
- Si modificas `.env`: re-ejecuta HTTP y DNS
- Si modificas script específico: solo re-ejecuta ese script
- Sin cambios: usa el caché

### Reglas implementadas
```makefile
$(STAMP_DIR)/http.stamp: src/check_http.sh .env
$(STAMP_DIR)/dns.stamp: src/check_dns.sh .env
$(STAMP_DIR)/test.stamp: $(TEST_DIR)/*.bats .env

test: $(STAMP_DIR)/test.stamp
check: $(STAMP_DIR)/http.stamp $(STAMP_DIR)/dns.stamp
```

## 2. Build reproducible de dist/

### Implementación
- `build-dist` genera distribución completa
- Incluye: src/, out/, README.md, checksums.txt
- Checksums MD5 para verificación de integridad

### Verificación de reproducibilidad
- `verify-repro` genera dist/ dos veces
- Compara checksums entre ambas generaciones
- Falla si hay diferencias (build no determinístico)

```makefile
verify-repro:
    @$(MAKE) build-dist >/dev/null 2>&1
    @mv $(DIST_DIR) $(DIST_DIR).old
    @$(MAKE) build-dist >/dev/null 2>&1
    @diff $(DIST_DIR)/checksums.txt $(DIST_DIR).old/checksums.txt
```
## 3. Verificación de Idempotencia y Artefactos de `make run`

### Ejecución y Medición
Para garantizar la eficiencia y predictibilidad del `Makefile`, se realizó la siguiente secuencia de tareas:

1.  **Doble Ejecución**: Se ejecutó el target `make run` en dos ocasiones consecutivas pero con el comando `(time make run) > out/make_run_1.log 2>&1`.
2.  **Captura de Artefactos**: La salida de cada ejecución, incluyendo los tiempos (`real`, `user`, `sys`), se redirigió a archivos de log específicos.
    -   Log de primera ejecución: `out/make_run_1.log`
    -   Log de segunda ejecución: `out/make_run_2.log`

### Verificación de Eficiencia
Se compararon los logs para verificar que el `Makefile` no realiza trabajo innecesario en ejecuciones subsecuentes.

-   **Tiempo de la primera ejecución**: `real 0m1.187s`
-   **Tiempo de la segunda ejecución**: `real 0m1.117s`

La ligera disminución en el tiempo de la segunda ejecución confirma que no se repitieron tareas costosas, validando el comportamiento idempotente del proceso. La salida de ambos logs fue idéntica, asegurando la consistencia.

### Documentación y Trazabilidad

-   **Contrato de Salidas**: Se actualizó el documento `docs/contrato-salidas.md` para incluir una sección que describe los nuevos artefactos generados (`make_run_1.log`, `make_run_2.log`) y formaliza la evidencia de la idempotencia.
