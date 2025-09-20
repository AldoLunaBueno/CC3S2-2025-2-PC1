#!/usr/bin/env bats

setup() {
  # Cargar variables de entorno desde .env si existe
  if [ -f ".env" ]; then
    source ".env"
  else
    skip "No se encontró .env"
  fi
}

@test "La URL de configuración responde correctamente" {
  run bash src/check_http.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "GET exitoso" ]]
}

@test "Detecta HTTP 404 correctamente" {
  # guardando el valor original
  ORIGINAL_CONFIG_URL=$(grep '^CONFIG_URL=' .env)
  # cambiando temporalmente el valor
  sed -i '/^CONFIG_URL=/c\CONFIG_URL="http://httpstat.us/404"' .env
  run bash src/check_http.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "GET falló" || "$output" =~ "POST falló" ]]
  # restaurando valor original
  sed -i "/^CONFIG_URL=/c\\$ORIGINAL_CONFIG_URL" .env
}

