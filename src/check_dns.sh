#!/usr/bin/env bash

verdeColor="\e[0;32m\033[1m"
finColor="\033[0m\e[0m"
rojoColor="\e[0;31m\033[1m"
azulColor="\e[0;34m\033[1m"
amarilloColor="\e[0;33m\033[1m"
moradoColor="\e[0;35m\033[1m"
turquesaColor="\e[0;36m\033[1m"
grisColor="\e[0;37m\033[1m"

# Funcion para mostrar ayuda
show_help() {
    echo -e "\n${amarilloColor}[■]${finColor}${grisColor} Uso: $0 ${finColor}${moradoColor}[A|AAAA|MX|NS|TXT]${finColor}\n"
    echo -e "\t${turquesaColor}- Descripción:${finColor}${grisColor} Resuelve registros DNS usando dig con dominios definidos en ${finColor}${amarilloColor}.env${finColor}"
    echo -e "\t${turquesaColor}- Variables:${finColor}${grisColor} TARGETS, DNS_SERVER ${finColor}"
    echo -e "\t${turquesaColor}- Códigos de salida:${finColor} ${verdeColor}0 = ok${finColor}, ${rojoColor}≠0 = falla${finColor}\n"
}

# Función para verificar si dig está disponible
check_dig() {
    if ! command -v dig &> /dev/null; then
        echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: dig no está instalado">&2
        return 1
    fi
}

# Función para resolver DNS
resolve_dns() {
    local domain="$1"
    local record_type="$2"
    local dns_server="$3"
    local output_file="out/dns_${record_type}_${domain}_$(date +%d-%b-%Y_%H%M%S).txt"
    
    echo -e "${azulColor}Resolviendo $record_type para: $domain usando servidor: $dns_server${finColor}"
    
    # Ejecutar dig y capturar la salida
    if dig @"$dns_server" "$domain" "$record_type" +short +time=5 > "$output_file" 2>&1; then
        local result_count=$(wc -l < "$output_file")
        if [ "$result_count" -gt 0 ]; then
            echo -e "\n${verdeColor}[✓]${finColor}${grisColor} Resolución exitosa - $result_count registro(s) encontrado(s)${finColor}"
            echo -e "${verdeColor}[✓]${finColor}${grisColor} Resultado guardado en: $output_file${finColor}\n"
            
            # Mostrar resultado breve
            echo -e "${azulColor}  Registros:${finColor}"
            while IFS= read -r line; do
                [ -n "$line" ] && echo "    $line"
            done < "$output_file"
            
            return 0
        else
            echo -e "\n${rojoColor}[✗]${finColor} ${grisColor}No se encontraron registros para: $domain${finColor}" >&2
            return 1
        fi
    else
        echo -e "\n${rojoColor}[✗]${finColor} ${grisColor}Fallo en resolución DNS para: $domain${finColor}" >&2
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

RECORD_TYPE="${1:-A}"

# Crear directorio de salida si no existe
mkdir -p out

# Verificar dependencias
check_dig

if [ -z "${TARGETS:-}" ]; then
    echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Variable TARGETS no definida en .env${finColor}">&2
    exit 1
fi

if [ -z "${DNS_SERVER:-}" ]; then
    echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Variable DNS_SERVER no definida en .env${finColor}">&2
    exit 1
fi

echo -e "\n${amarilloColor}=== Resolución DNS usando variables de entorno ===${finColor}\n"
echo -e "${grisColor}Servidor DNS: $DNS_SERVER${finColor}"
echo -e "${grisColor}Tipo de registro: $RECORD_TYPE${finColor}"
echo -e "${grisColor}Dominios objetivo: $TARGETS${finColor}"

# Validar tipo de registro
case "$RECORD_TYPE" in
    A|AAAA|MX|NS|TXT|a|aaaa|mx|ns|txt)
        RECORD_TYPE=$(echo "$RECORD_TYPE" | tr '[:lower:]' '[:upper:]')
        ;;
    *)
        echo -e "\n${rojoColor}[!]${finColor} ${grisColor}Error: Tipo de registro no soportado: $RECORD_TYPE${finColor}">&2
        echo -e "${grisColor}    Tipos soportados: ${finColor}${moradoColor}A, AAAA, MX, NS, TXT${finColor}"
        exit 1
        ;;
esac

# Procesar cada dominio en TARGETS
success_count=0
total_count=0

for domain in $TARGETS; do
    total_count=$((total_count + 1))
    
    # Limpiar dominio
    if [[ "$domain" == *"://"* ]]; then
        domain="${domain#*://}"
    fi
    if [[ "$domain" == *"/"* ]]; then
        domain="${domain%%/*}"
    fi
    
    echo -e "\n${moradoColor}--- Procesando dominio: $domain ---${finColor}"
    
    if resolve_dns "$domain" "$RECORD_TYPE" "$DNS_SERVER"; then
        success_count=$((success_count + 1))
    fi
done

if [ "$success_count" -eq "$total_count" ]; then
    echo -e "\n${verdeColor}=== Todas las resoluciones DNS completadas exitosamente ====${finColor}\n"
    exit 0
else
    echo -e "$\n{rojoColor}[!]${finColor} ${grisColor} Algunas resoluciones DNS fallaron${finColor}"
    echo -e "    ${grisColor} $success_count/$total_count resoluciones DNS fallaron${finColor}\n"
    exit 1
fi
