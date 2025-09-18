#!/usr/bin/env bats

setup() {
  # Cargar variables de entorno desde .env si existe
  if [ -f ".env" ]; then
    set -a
    source ".env"
    set +a
  else
    skip "No se encontró .env"
  fi
}

@test "Resuelve DNS y muestra registros para TARGETS" {
  run bash src/check_dns.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Resolución exitosa" ]]
}
