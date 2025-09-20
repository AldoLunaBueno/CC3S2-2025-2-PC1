#!/usr/bin/env bash

verdeColor="\e[0;32m\033[1m"
finColor="\033[0m\e[0m"
rojoColor="\e[0;31m\033[1m"
azulColor="\e[0;34m\033[1m"
amarilloColor="\e[0;33m\033[1m"
moradoColor="\e[0;35m\033[1m"
turquesaColor="\e[0;36m\033[1m"
grisColor="\e[0;37m\033[1m"

set -euo pipefail

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "${rojoColor}[!]${finColor} ${grisColor}Script terminado con error (código: $exit_code)${finColor}" >&2
    fi
    exit 0
}

trap cleanup EXIT
trap 'echo -e "${rojoColor}[!]${finColor} ${grisColor}Script interrumpido por el usuario${finColor}"; exit 130' INT TERM

# Funcion para mostrar ayuda
show_help() {
    echo -e "\n${amarilloColor}[■]${finColor}${grisColor} Uso: $0 ${finColor}${moradoColor}[GET|POST]${finColor}\n"
    echo -e "\t${turquesaColor}- Descripción:${finColor}${grisColor} Valida peticiones HTTP usando curl con URLs definidas en ${finColor}${amarilloColor}.env${finColor}"
    echo -e "\t${turquesaColor}- Variables:${finColor}${grisColor} CONFIG_URL, TARGETS, PORT, MESSAGE ${finColor}"
    echo -e "\t${turquesaColor}- Códigos de salida:${finColor} ${verdeColor}0 = ok${finColor}, ${rojoColor}≠0 = falla${finColor}\n"
}

# Función para validar URL
validate_url() {
    local url="$1"
    url=$(echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: URL debe comenzar con http:// o https://${finColor}">&2
        return 1
    fi
    return 0
}

# Función para realizar petición GET
check_get() {
    local url="$1"
    local output_file="out/http_get_$(basename "$url")_$(date +%d-%b-%Y_%H%M%S).txt"
    
    echo -e "\n${moradoColor}Realizando petición GET a: $url ${finColor}"
    
    if curl -s -f -o "$output_file" \
       -w "- HTTP Status: %{http_code}\n- Time: %{time_total}s\n- Size: %{size_download} bytes" "$url"; then
        echo -e "\n${verdeColor}[✓]${finColor} ${grisColor} GET exitoso - Resultado guardado en: $output_file ${finColor}\n"
        return 0
    else
        echo -e "\n${rojoColor}[✗]${finColor} ${grisColor}GET falló para: $url ${finColor}" >&2
        return 1
    fi
}

# Función para realizar petición POST
check_post() {
    local url="$1"
    local output_file="out/http_post_$(basename "$url")_$(date +%d-%b-%Y_%H%M%S).txt"
    
    echo -e "\n${moradoColor}Realizando petición POST a: $url ${finColor}"
    
    # POST con datos que incluyen variables de entorno
    local post_data='{"message": "'"$MESSAGE"'", "release": "'"$RELEASE"'", "port": '"$PORT"', "timestamp": "'$(date -I)'"}'
    
    if curl -s -f -X POST -H "Content-Type: application/json" -d "$post_data" -o "$output_file" \
       -w "- HTTP Status: %{http_code}\n- Time: %{time_total}s\n- Size: %{size_download} bytes\n" "$url"; then
        echo -e "\n${verdeColor}[✓]${finColor}${grisColor} Resultado guardado en: $output_file ${finColor}\n"
        return 0
    else
        echo -e "\n${rojoColor}[✗]${finColor}${grisColor} POST falló para: $url ${finColor}" >&2
        return 1
    fi
}

# Valida si existe .env
if [ -f ".env" ]; then
    source ".env"
else
    echo -e "\n${rojoColor}[!]${finColor} ${grisColor}ERROR: No se encontro '.env':${finColor}">&2
    exit 1
fi

# Verificar argumentos
if [ $# -gt 1 ]; then
    echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Número incorrecto de argumentos${finColor}">&2
    show_help
    exit 1
fi

# Verificar que la URL este definida
if [ -z "${CONFIG_URL:-}" ]; then
    echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Variable CONFIG_URL no definida en entorno${finColor}">&2
    exit 1
fi

METHOD="${1:-GET}"

# Crear directorio de salida si no existe
mkdir -p out

# Si la URL termina en dominio base, agregar ruta según método
main_url="$CONFIG_URL"
main_url=$(echo "$main_url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [[ "$main_url" =~ ^https?://[^/]+/?$ ]]; then
    case "$METHOD" in
        GET|get)
            main_url="${main_url%/}/get"
            ;;
        POST|post)
            main_url="${main_url%/}/post"
            ;;
    esac
fi

echo -e "\n${amarilloColor}=== Validación HTTP usando variables de entorno ===${finColor}\n"
echo -e "${grisColor}Mensaje: $MESSAGE${finColor}"
echo -e "${grisColor}Release: $RELEASE${finColor}"
echo -e "${grisColor}Puerto: $PORT${finColor}"
echo -e "${grisColor}URL de configuración: $main_url${finColor}"

# Validar URL principal
validate_url "$main_url"

# Ejecutar según el método
case "$METHOD" in
    GET|get)
        check_get "$main_url" || exit 1
        ;;
    POST|post)
        check_post "$main_url" || exit 1
        ;;
    *)
        echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Método no soportado: $METHOD${finColor}">&2
        echo -e "${grisColor}    Métodos soportados: ${finColor}${moradoColor}GET, POST${finColor}"
        exit 0
        ;;
esac

# Validacion de TARGETS
if [ -n "${TARGETS:-}" ]; then
    echo -e "${amarilloColor}=== Validación de URLs adicionales de TARGETS ===${finColor}\n"
    for target in $TARGETS; do
        # Agregar protocolo si no lo tiene
        if [[ ! "$target" =~ ^https?:// ]]; then
            target="http://$target"
        fi
        
        echo -e "${azulColor}Validando: $target${finColor}"
        case "$METHOD" in
            GET|get)
                check_get "$target" || echo -e "${rojoColor}[!]${finColor} ${grisColor}Fallo en $target, continuando...${finColor}"
                ;;
            POST|post)
                check_post "$target" || echo -e "${rojoColor}[!]${finColor} ${grisColor}Fallo en $target, continuando...${finColor}"
                ;;
        esac
    done
fi

echo -e "${verdeColor}=== Validación HTTP completada exitosamente ===${finColor}\n"