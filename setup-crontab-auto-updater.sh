#!/bin/bash

SCRIPT_NAME="auto-updater.sh"
CRON_INTERVAL="*/5 * * * *"
CRON_LOG="cron_update.log"

# Ruta absoluta al script
REPO_PATH=$(pwd)
SCRIPT_PATH="$REPO_PATH/$SCRIPT_NAME"

# Validar que el script existe
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "❌ No se encuentra el script '$SCRIPT_NAME' en $REPO_PATH"
  exit 1
fi

# Línea cron que queremos agregar
CRON_JOB="$CRON_INTERVAL cd $REPO_PATH && ./$SCRIPT_NAME >> $CRON_LOG 2>&1"

# Comprobar si ya existe
(crontab -l 2>/dev/null | grep -F "$SCRIPT_NAME") >/dev/null

if [ $? -eq 0 ]; then
  echo "✅ El cron ya existe. No se añadirá duplicado."
else
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "✅ Tarea programada cada 5 minutos para ejecutar '$SCRIPT_NAME'."
fi
