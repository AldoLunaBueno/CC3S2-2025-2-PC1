## Variables de entorno (12-Factor III)

| Variable   | Descripción | Ejemplo | Efecto observable |
|------------|-------------|---------|--------------------|
| PORT       | Puerto usado por el pipeline para exponer/validar los servicios HTTP | 8080 | `curl localhost:$PORT` debe responder |
| MESSAGE    | Mensaje mostrado en logs/scripts | "Pipeline HTTP/DNS activo" | `src/mostrar_env.sh` imprime el mensaje |
| RELEASE    | Versión del release en curso | v0.0.1 | Aparece en bitácora y logs |
| CONFIG_URL | URL remota de configuración | https://example.com/config.json | Se descarga y procesa para validaciones |
| DNS_SERVER | Servidor DNS a usar | 8.8.8.8 | `dig @$DNS_SERVER example.com` debe funcionar |
| TARGETS    | Lista de dominios a validar | "example.com" | Los scripts HTTP/DNS iterarán sobre ellos |
