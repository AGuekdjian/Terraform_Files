#!/bin/bash

check_exit_code() {
    if [ $? -e 0 ]; then
    echo "$2\n"
    elif [ $? -ne 0 ]; then
    echo "Ah ocurrido un error: $1\n" >> logs.txt
    exit 1
    fi
}

sudo apt update && sudo apt upgrade -y
check_exit_code "Error en la actualizacion del sistema" "Actualizando lista de paquetes y sistema"

mkdir app
check_exit_code "Error al crear directorio app" "Creando directorio app"

sudo apt install git -y && cd app/ && git clone https://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@github.com/AGuekdjian/Red-Social.git && cd ..
check_exit_code "Error al clonar el repositorio" "Clonando repositorio en el directorio de app"

git clone https://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@github.com/AGuekdjian/Scripts.git && mv ./Scripts/installDocker.sh . && rm -rf ./Scripts
check_exit_code "Error al clonar el repositorio de scripts" "Clonando repositorio scripts, extrayendo instalador de docker y eliminando archivos o directorios inecesarios"

./installDocker.sh && rm -rf ./installDocker.sh
check_exit_code "Fallo la instalacion de Docker" "instalando Docker y eliminando archivos y directorios inecesarios."

cd app/Red-Social && ./Docker.sh
check_exit_code "Error al levantar docker compose" "Levantando docker compose, ejecutando aplicacion"

sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8000
check_exit_code "Error al intentar redireccionar puertos" "Redireccionando al puerto 8000"