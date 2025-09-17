#!/usr/bin/env bats

setup() {
  # Cargar variables de entorno desde .env si existe
  if [ -f ".env" ]; then
    source ".env"
  else
    skip "No se encontró .env"
  fi
}

@test "La URL de configuración responde con 200" {
  run curl -s -o /dev/null -w "%{http_code}" "$CONFIG_URL"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}