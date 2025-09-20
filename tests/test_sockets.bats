#!/usr/bin/env bats

setup() {
  # Cargar variables de entorno desde .env si existe
  if [ -f ".env" ]; then
    source ".env"
  else
    skip "No se encontró .env"
  fi
}

@test "Listar sockets abiertos con ss" {
  run ss -tuln
  [ "$status" -eq 0 ]
  [[ "$output" =~ "LISTEN" ]]
}

@test "Conexión exitosa con nc a puerto abierto" {
  # iniciar un servidor HTTP en segundo plano
  python3 -m http.server "$PORT" >/dev/null 2>&1 &
  SERVER_PID=$!
  # esperando para que el servidor inicie
  sleep 1
  # probando conexión
  run nc -zv localhost "$PORT"
  # deteniendo el servidor
  kill $SERVER_PID
  [ "$status" -eq 0 ]
}

@test "Conexión fallida con nc a puerto cerrado" {
  run nc -zv localhost "$PORT"
  [ "$status" -ne 0 ]
}