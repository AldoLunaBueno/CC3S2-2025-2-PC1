# CC3S2-2025-2-PC1
Proyecto 3: Pipeline de validación de protocolos HTTP/DNS

Este documento resume el trabajo realizado en cada sprint.

Cada **sprint** fue documentado en su respectiva bitácora en el directorio `docs/`.

---

## **Sprint 1**

El objetivo de este sprint fue establecer la base del proyecto con la estructura de repositorio, configuración por variables de entorno, primeros chequeos HTTP/DNS y un Makefile inicial con pruebas Bats.

Se creó el repositorio en GitHub con el nombre `pipeline-http-dns` y se configuraron ramas personales (`rama/A`, `rama/B`, `rama/C`) junto con reglas de protección en `main` y `develop`.  
Se redactó `docs/README.md` con la política de commits en español y el flujo de PRs.  
El primer commit incluyó la estructura mínima de directorios:  
```
src/
tests/
docs/
out/
dist/
```
Se declararon variables de entorno (`PORT`, `MESSAGE`, `RELEASE`, `CONFIG_URL`, `DNS_SERVER`, `TARGETS`) y se añadió una tabla en `docs/README.md` explicando su efecto observable.  
Se desarrolló el script `src/print_env.sh` para imprimir el estado de las variables cargadas.  
El uso y carga de variables quedó documentado en `docs/bitacora-sprint-1.md`.

Se implementaron los primeros chequeos:  
- `src/check_http.sh` para validar métodos `GET` y `POST` usando `curl`, con códigos de salida claros (`0=ok`, distinto de `0=falla`).  
- `src/check_dns.sh` para resolver registros `A` y obtener TTL con `dig`.  

Los comandos y salidas se documentaron en `docs/bitacora-sprint-1.md` y los resultados reproducibles se guardaron en `out/`.

Se creó un Makefile con los targets básicos (`tools`, `build`, `test`, `run`, `pack`, `clean`, `help`) y se añadió la regla `.PHONY` para los que no generan archivos.  
En `tests/test_http.bats` se implementó una prueba mínima que valida un código `200` en `curl`.  
El uso del Makefile quedó documentado en `docs/bitacora-sprint-1.md` y el resultado de la primera prueba se almacenó en `out/`.

---

## **Sprint 2**

El objetivo de este sprint fue robustecer los scripts Bash, simular procesos y señales, y ampliar pruebas con Bats.

Se añadieron medidas de robustez en los scripts principales (`set -euo pipefail` y `trap`).  
Se implementó limpieza automática en caso de error (eliminación de archivos temporales y sockets).    
Los códigos de salida se documentaron en `out/`.

Se desarrolló el script `src/run_service.sh` para ejecutar un servicio en segundo plano.  
Se añadió el manejo de señales (`SIGTERM`) para parada limpia y se simularon permisos de usuarios/grupos dentro del proyecto.  
La documentación de estas actividades se realizó en `docs/bitacora-sprint-2.md`, y se incluyeron logs con `journalctl` como evidencia.

Se ampliaron las pruebas en Bats para cubrir:  
- Resolución DNS y verificación de TTL.  
- Fallos HTTP controlados (`404`).  
- Robustez ante errores (salidas distintas de 0).  

También se validó la apertura de sockets con `ss` y la conexión con `nc`.  
Los resultados quedaron registrados en `docs/bitacora-sprint-2.md` y los reportes en `out/`.

---

## Sprint 3

El objetivo de este sprint fue integrar el proyecto en su versión final, implementar caché incremental en Makefile, validar idempotencia y realizar el cierre del proyecto.

Se implementaron reglas patrón en el Makefile para la carpeta `out/` y se configuró un sistema de caché incremental, evitando rehacer tareas cuando las dependencias no cambiaban.  
Se validó la reproducibilidad de los artefactos en `dist/` y se documentaron las evidencias en `docs/bitacora-sprint-3.md`.  
Los resultados fueron almacenados en `out/`.

Se comprobó la idempotencia ejecutando `make run` en dos ocasiones, midiendo tiempos y artefactos para confirmar que no se rehacía trabajo innecesario.  
Se consolidó el contrato de salidas en `docs/contrato-salidas.md` y se documentó la trazabilidad en `docs/bitacora-sprint-3.md`.  
Logs y capturas adicionales quedaron guardados en `out/`.

Se aplicó un checklist de revisión con evidencia y se documentó el proceso en `docs/bitacora-sprint-3.md`.
