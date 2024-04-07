#!/bin/sh 

# VARS
user=admin # Sonar user
password=admin1 # Sonar password

# CONSTS
projectKey=sakai2
projectName=Sakai
tokenName=sakai_token3
folder=${1:-"."}

# Handling Ctrl+C
ctrl_c() {
    echo "[!] Saliendo..."
    exit 1
}
trap ctrl_c SIGINT

# Show working path
echo "[+] Proyecto elegido: $folder"

# Check Sonar started
if lsof -Pi :9000 -sTCP:LISTEN -t >/dev/null; then
    echo "[+] SonarQube iniciado"
else
    echo "[!] SonarQube debe estar iniciado"
    echo "[!] Saliendo..."
    exit 1
fi


# Check Sonar project created
response=$(curl -s -u $user:$password -X GET "http://localhost:9000/api/projects/search?projects=$projectKey")
total=$(echo "$response" | awk -F'"total":|}' '{print $2}')

if [ "$total" -ne 1 ]; then
    # Create project
    curl -s -u $user:$password -X POST "http://localhost:9000/api/projects/create?name=$projectName&project=$projectKey"
fi

# Generate token
response=$(curl -s -u $user:$password -X POST "http://localhost:9000/api/user_tokens/generate?name=$tokenName&type=PROJECT_ANALYSIS_TOKEN&projectKey=$projectKey")

# Verifica si hay un campo "error" en el JSON de la respuesta
if echo "$response" | grep -q '"errors":'; then
    # El token ya existe
    token=$(cat $folder/.token)
else
    # El token no existe
    token=$(echo "$response" | grep -o '"token": *"[^"]*"' | awk -F'"' '{print $4}')
    # Guardando token en local
    echo $token > $folder/.token
fi

# Analizando proyecto

# Set Temurin 17
echo "[+] Setting Temurin 17: temurin-17-jdk-amd64"
sudo update-java-alternatives --set temurin-17-jdk-amd64  
if [ "$?" -eq 1 ]; then
    echo "[!] temurin-17-jdk-amd64 no encontrado. Instala Temurin 17 y vuelve a ejecutar el script"
fi

cd $folder
echo "[+] Analizando proyecto!"
mvn sonar:sonar \
  -Dsonar.projectKey=$projectKey \
  -Dsonar.projectName=$projectName \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=$token

# Compilación y empaquetado

# Set java 11
echo "[+] Setting Java 11: java-1.11.0-openjdk-amd64"
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
if [ "$?" -eq 1 ]; then
    echo "[!] java-1.11.0-openjdk-amd64 no encontrado. Instala Java 11 y vuelve a ejecutar el script"
fi
echo "[+] Compilando y empaquetando proyecto!"

mvn clean install

# Outro
echo "[#] SCRIPT FINALIZADO CORRECTAMENTE"
echo "[#] Reporte: http://localhost:9000/dashboard?id=$projectKey"
echo "[#] Ruta de ejecutables: $folder/<modulo>/target/"

