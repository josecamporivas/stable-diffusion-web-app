#!/bin/bash

# Configuración
BRANCH="main"

echo "Comprobando cambios en el repositorio..."

# Obtener el último commit local y remoto
git fetch origin "$BRANCH"

LOCAL_HASH=$(git rev-parse "$BRANCH")
REMOTE_HASH=$(git rev-parse "origin/$BRANCH")

echo "Commit local:  $LOCAL_HASH"
echo "Commit remoto: $REMOTE_HASH"

# Comprobar si hay cambios
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
  echo "Hay un nuevo commit. Actualizando..."
  git pull origin "$BRANCH"

  echo "Deteniendo contenedores..."
  docker compose down

  echo "Eliminando imágenes antiguas..."
  docker rmi sd-backend sd-frontend || echo "Las imágenes no existen o ya fueron eliminadas"

  echo "Reconstruyendo y levantando servicios..."
  docker compose up -d --force-recreate --build

  echo "Actualización completada."
else
  echo "No hay nuevos commits. Todo está actualizado."
fi
