# Bitácora Sprint 1

### **Carga de variables**

Debido a que es una mala práctica añadir el archivo `.env` al repositorio remoto, entonces se crea el archivo `docs/.env.example`, lo cual ayudará a los miembros del grupo (o personas externas) a tener una ídea del formato que debe tener el archivo `.env` para este proyecto.

Simplemente se devería ejecutar en la raiz del proyecto:

```bash
cp docs/.env.example .env
```
Ahora, en el nuevo archivo `.env`, modificar las variables con los valores correctos para su uso.

Para cargar los valores de entorno, se debe ejecutar el script `cargar_env.sh`, ubicado en el directorio `src`:

```bash
source src/cargar_env.sh
```

Y para verificar que las variables se cargaron éxitosamente, se debe ejecutar el script `mostrar_env.sh`, ubicado en el directorio `src` (dar permisos de ejecución previamente):

```bash
./src/mostrar_env.sh
```

### **Validaciones HTTP y DNS**

Se implementaron dos scripts principales para realizar validaciones de conectividad y disponibilidad de servicios, utilizando las variables de entorno definidas en el archivo `.env` para una configuración centralizada.

#### **Script de validación HTTP**

El script `check_http.sh` permite validar endpoints HTTP mediante peticiones GET y POST utilizando `curl`. Este script es útil para:
- Monitorear la disponibilidad de APIs y servicios web
- Validar endpoints antes de despliegues
- Realizar health checks automáticos de microservicios

Para ejecutar validaciones HTTP:

```bash
# Validación GET (método por defecto)
./src/check_http.sh

# Validación explícita
./src/check_http.sh GET
./src/check_http.sh POST
```

El script utiliza las variables `CONFIG_URL` y `TARGETS` del archivo `.env` para determinar qué endpoints validar, y guarda los resultados en el directorio `out/` con timestamps para trazabilidad.

#### **Script de validación DNS**

El script `check_dns.sh` permite resolver registros DNS utilizando `dig` para verificar la configuración y disponibilidad de dominios. Es útil para:
- Validar resolución de dominios tras cambios de DNS
- Monitorear la propagación de registros DNS
- Diagnosticar problemas de conectividad de red

Para ejecutar validaciones DNS:

```bash
# Registros A (por defecto)
./src/check_dns.sh

# Registros específicos
./src/check_dns.sh A
./src/check_dns.sh MX
./src/check_dns.sh NS
./src/check_dns.sh TXT
./src/check_dns.sh AAAA
```

El script procesa los dominios listados en la variable `TARGETS` utilizando el servidor DNS especificado en `DNS_SERVER`, guardando los resultados de cada consulta en archivos individuales.

#### **Resultados reproducibles**

Ambos scripts guardan sus resultados en el directorio `out/` con nomenclatura estandarizada:
- HTTP: `http_{get|post}_{url}_{timestamp}.txt`
- DNS: `dns_{tipo}_{dominio}_{timestamp}.txt`

Esto permite mantener un historial de validaciones y facilita el debugging de problemas intermitentes.