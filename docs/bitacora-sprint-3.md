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
