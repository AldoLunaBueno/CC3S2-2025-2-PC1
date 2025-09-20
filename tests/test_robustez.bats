#!/usr/bin/env bats

setup() {
  # Cargar variables de entorno desde .env si existe
  if [ -f ".env" ]; then
    source ".env"
  else
    skip "No se encontró .env"
  fi
}

@test "Fallo controlado en la resolución DNS para dominio inválido" {
  # guardando el valor original
  ORIGINAL_TARGETS=$(grep '^TARGETS=' .env)
  # cambiando temporalmente el valor
  sed -i 's/^TARGETS=.*/TARGETS="dominio-inexistente-xyz123.com"/' .env
  run bash src/check_dns.sh
  [ "$status" -ne 0 ]
  [[ "$output" =~ "No se encontraron registros" || "$output" =~ "Fallo en resoluci" ]]
  # restaurando valor original
  sed -i "s/^TARGETS=.*/$ORIGINAL_TARGETS/" .env
}

@test "Fallo controlado en URL inválida" {
  ORIGINAL_CONFIG_URL=$(grep '^CONFIG_URL=' .env)
  sed -i '/^CONFIG_URL=/c\CONFIG_URL=" "' .env
  run bash src/check_http.sh "GET"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "URL debe comenzar" ]]
  sed -i "/^CONFIG_URL=/c\\$ORIGINAL_CONFIG_URL" .env
}