#!/bin/sh 

# CONSTS
sakaiFolder=sakai/kernel/component-manager
ebFolder=easybuggy
originalFolder=$(pwd)

# Handling Ctrl+C
ctrl_c() {
    echo "[!] Saliendo..."
    exit 1
}
trap ctrl_c SIGINT

## VALORES POR DEFECTO
echo "[+] Rutas por defecto"
echo -e "\tSAKAI: $sakaiFolder/"
echo -e "\tEASYBUGGY: $ebFolder/"

## REQUISITOS

# Check PMD & download it
$HOME/pmd-bin-7.0.0/bin/pmd > /dev/null 2>&1
if [ "$?" -eq 127 ]; then
    echo "[-] No existe PMD"
    echo "[+] Descargando PMD"
    wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip -P $HOME
    unzip $HOME/pmd-dist-7.0.0-bin.zip
    rm $HOME/pmd-dist-7.0.0-bin.zip
fi

# Setting Java 11
echo "[+] Setting Java 11: java-1.11.0-openjdk-amd64"
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
if [ "$?" -eq 1 ]; then
    echo "[!] java-1.11.0-openjdk-amd64 no encontrado. Instala Java 11 y vuelve a ejecutar el script"
fi

## SAKAI
echo -e "\n[#] --- SAKAI ---"

# Analizando proyecto
echo "[+] Analizando proyecto!"
$HOME/pmd-bin-7.0.0/bin/pmd check -d $sakaiFolder -R rulesets/java/quickstart.xml -f summaryhtml -r report.html

# Compilación y empaquetado
echo "[+] Compilando y empaquetando!"
cd $sakaiFolder
mvn clean install -DskipTests

## EASYBUGGY
echo -e "\n[#] --- EASYBUGGY ---"

# Compilación y empaquetado
echo "[+] Compilando y empaquetando!"
cd $originalFolder
cd $ebFolder
mvn package


# Outro
echo -e "\n[#] SCRIPT FINALIZADO CORRECTAMENTE"
echo "[#] Reporte: report.html"
echo "[#] Ruta de ejecutables:"
echo -e "\tSAKAI: target/ dentro de $sakaiFolder"
echo -e "\tEASYBUGGY: $ebFolder/target/easybuggy.jar"

