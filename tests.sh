#!/bin/sh 

# CONSTS
folder=${1:-"."}

# Handling Ctrl+C
ctrl_c() {
    echo "[!] Saliendo..."
    exit 1
}
trap ctrl_c SIGINT

# Show working path
echo "[+] Proyecto elegido: $folder"

# Testing

# Set java 11
echo "[+] Setting Java 11: java-1.11.0-openjdk-amd64"
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
if [ "$?" -eq 1 ]; then
    echo "[!] java-1.11.0-openjdk-amd64 no encontrado. Instala Java 11 y vuelve a ejecutar el script"
fi
echo "[+] Ejecutando tests del proyecto!"

cd $folder
mvn test

# Outro
echo "[#] SCRIPT FINALIZADO CORRECTAMENTE"


