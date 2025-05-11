#!/bin/bash

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

################################
# TODO: check if docker is installed
################################

## TODO: when I have to restart the server I have to delete all images

set -e

if command -v docker &> /dev/null
then
    echo "Docker ya está instalado."
else
    echo "Docker no está instalado. Iniciando instalación..."

    # Actualiza los paquetes
    sudo apt update
    sudo apt get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt get update
    sudo apt get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verifica la instalación
    if command -v docker &> /dev/null
    then
        echo "Docker se instaló correctamente."
    else
        echo "Hubo un error al instalar Docker."
    fi
fi

echo "🚀 Verificando si tienes una GPU NVIDIA..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ No se detectó 'nvidia-smi'. Instala los drivers de NVIDIA antes de continuar."
    exit 1
fi

echo "✅ GPU NVIDIA detectada."

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

echo "🔧 Instalando nvidia-container-toolkit..."
sudo apt update
sudo apt install -y nvidia-container-toolkit

echo "🔁 Reiniciando Docker..."
sudo systemctl restart docker

echo "🛠️ Configurando Docker para usar el runtime NVIDIA por defecto..."

DOCKER_CONFIG_FILE="/etc/docker/daemon.json"

sudo bash -c "cat > $DOCKER_CONFIG_FILE" <<EOF
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF

echo "🔁 Reiniciando Docker nuevamente con configuración actualizada..."
sudo systemctl restart docker

echo "🧪 Verificando acceso a la GPU desde Docker..."
docker run --rm --gpus all nvidia/cuda:11.8.0-base nvidia-smi

echo "✅ Configuración completa. Docker ya puede usar tu GPU NVIDIA."
