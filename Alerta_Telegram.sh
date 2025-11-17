#!/bin/bash
# Script para enviar alerta por Telegram si cambia usernames.txt

# --- Configuración ---
BOT_TOKEN="BOT_TOKEN"
CHAT_ID="CHAT_ID"  
        
# puede ser ID de usuario o grupo
ARCHIVO="/var/www/html/usernames.txt"
HASH_FILE="/tmp/x_hash_anterior_envio.txt"

# --- Rutas completas de comandos ---
CMD_MD5SUM="/usr/bin/md5sum"
CMD_AWK="/usr/bin/awk"
CMD_CURL="/usr/bin/curl"
CMD_TAIL="/usr/bin/tail"
CMD_DATE="/usr/bin/date"
# -----------------------------------

# 1. Si no existe el archivo, salimos sin ruido
if [ ! -f "$ARCHIVO" ]; then
  exit 0
fi

# 2. Calcular hash actual
HASH_ACTUAL=$($CMD_MD5SUM "$ARCHIVO" | $CMD_AWK '{print $1}')

# 3. Si no hay hash previo, lo guardamos y salimos (primera ejecución)
if [ ! -f "$HASH_FILE" ]; then
  echo "$HASH_ACTUAL" > "$HASH_FILE"
  exit 0
fi

# 4. Leer hash anterior
HASH_ANTERIOR=$(cat "$HASH_FILE")

# 5. Si cambió, mandamos mensaje a Telegram
if [ "$HASH_ACTUAL" != "$HASH_ANTERIOR" ]; then
  FECHA=$($CMD_DATE '+%Y-%m-%d %H:%M:%S')

  MENSAJE="Nuevo registro en usernames.txt
Fecha/hora: $FECHA

Últimas 4 líneas:
$($CMD_TAIL -n 4 "$ARCHIVO")"

  $CMD_CURL -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
       -F chat_id="$CHAT_ID" \
       -F text="$MENSAJE"

  # Guardar nuevo hash
  echo "$HASH_ACTUAL" > "$HASH_FILE"
fi

exit 0