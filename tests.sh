#!/bin/sh 

# CONSTS
sakaiFolder=/var/lib/jenkins/scripts/auto-sakai/sakai/kernel/component-manager

# Handling Ctrl+C
ctrl_c() {
    echo "[!] Saliendo..."
    exit 1
}
trap ctrl_c SIGINT

## VALORES POR DEFECTO
echo "[+] Rutas por defecto"
echo -e "\tSAKAI: $sakaiFolder/"

## REQUISITOS

# Setting Java 11
echo "[+] Setting Java 11: java-1.11.0-openjdk-amd64"
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
if [ "$?" -eq 1 ]; then
    echo "[!] java-1.11.0-openjdk-amd64 no encontrado. Instala Java 11 y vuelve a ejecutar el script"
fi

## SAKAI
echo -e "\n[#] --- SAKAI ---"
echo "[+] Ejecutando tests del proyecto!"

cd $sakaiFolder
mvn test

# Outro
echo -e "\n[#] SCRIPT FINALIZADO CORRECTAMENTE"


