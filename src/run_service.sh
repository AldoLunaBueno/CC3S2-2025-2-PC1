#!/usr/bin/env bash
set -euo pipefail

LOGFILE="out/service.log"
PIDFILE="out/service.pid"

# Simular permisos restrictivos (umask)
umask 027

# Función para terminar limpio
cleanup() {
    echo "$(date +"%F %T") - Recibí SIGTERM, cerrando servicio..." >> "$LOGFILE"
    rm -f "$PIDFILE"
    exit 0
}

trap cleanup SIGTERM

mkdir -p out
echo $$ > "$PIDFILE"
echo "$(date +"%F %T") - Servicio iniciado con PID $$" >> "$LOGFILE"

# Simulación: bucle infinito validando algo cada 2s
while true; do
    echo "$(date +"%F %T") - Validando targets (ejemplo: google.com)" >> "$LOGFILE"
    sleep 5
done
