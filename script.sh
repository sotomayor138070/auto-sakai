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

# Check PMD & download it
$HOME/pmd-bin-7.0.0/bin/pmd > /dev/null 2>&1
if [ "$?" -eq 127 ]; then
    echo "[-] No existe PMD"
    echo "[+] Descargando PMD"
    wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip -P $HOME
    unzip $HOME/pmd-dist-7.0.0-bin.zip
    rm $HOME/pmd-dist-7.0.0-bin.zip
fi

# Analizando proyecto
echo "[+] Analizando proyecto!"
$HOME/pmd-bin-7.0.0/bin/pmd check -d $folder -R rulesets/java/quickstart.xml -f summaryhtml -r report.html

# Compilación y empaquetado

# Set java 11
echo "[+] Setting Java 11: java-1.11.0-openjdk-amd64"
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
if [ "$?" -eq 1 ]; then
    echo "[!] java-1.11.0-openjdk-amd64 no encontrado. Instala Java 11 y vuelve a ejecutar el script"
fi
echo "[+] Compilando y empaquetando proyecto!"

cd $folder
mvn clean install

# Outro
echo "[#] SCRIPT FINALIZADO CORRECTAMENTE"
echo "[#] Reporte: report.html"
echo "[#] Ruta de ejecutables: $folder/<modulo>/target/"

