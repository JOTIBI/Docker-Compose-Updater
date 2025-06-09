#!/bin/bash

# Docker Compose Updater Script
# Developed and proudly powered by JOTIBI

# ========== DEPENDENCY CHECK ==========
REQUIRED_CMDS=(docker)
MISSING=()

for CMD in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$CMD" &>/dev/null; then
    MISSING+=("$CMD")
  fi
done

# Check for docker compose variants
if command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null; then
  COMPOSE_CMD="docker compose"
else
  MISSING+=("docker-compose or docker compose")
fi

if [ ${#MISSING[@]} -ne 0 ]; then
  echo "Fehlende Tools: ${MISSING[*]}"
  read -p "Jetzt installieren? (y/n): " INSTALL_CHOICE
  INSTALL_CHOICE=${INSTALL_CHOICE:-n}
  if [[ "$INSTALL_CHOICE" =~ ^[Yy]$ ]]; then
    apt update
    apt install -y docker docker-compose
  else
    echo "Bitte installiere die fehlenden Tools manuell."
    exit 1
  fi
fi

clear

# ASCII Logo
cat << "EOF"
   _____            _        _                   _    _           _       _            
  / ____|          | |      (_)                 | |  | |         | |     | |           
 | |     ___  _ __ | |_ __ _ _ _ __   ___ _ __  | |  | |_ __   __| | __ _| |_ ___ _ __ 
 | |    / _ \| '_ \| __/ _` | | '_ \ / _ \ '__| | |  | | '_ \ / _` |/ _` | __/ _ \ '__|
 | |___| (_) | | | | || (_| | | | | |  __/ |    | |__| | |_) | (_| | (_| | ||  __/ |   
  \_____\___/|_| |_|\__\__,_|_|_| |_|\___|_|     \____/| .__/ \__,_|\__,_|\__\___|_|   
                                                       | |                             
                                                       |_|                             
==== Docker Compose Updater - Created by JOTIBI ====
EOF

# Ask for path
while true; do
  read -p "Pfad zum Docker Compose Projekt (default: ./): " PROJECT_PATH
  PROJECT_PATH=${PROJECT_PATH:-./}
  if [ -f "$PROJECT_PATH/docker-compose.yml" ]; then
    break
  else
    echo "Keine docker-compose.yml gefunden. Bitte erneut versuchen."
  fi
done

cd "$PROJECT_PATH" || exit 1

read -p "Container im Pfad '$PROJECT_PATH' jetzt updaten? (y/n): " CONFIRM
CONFIRM=${CONFIRM:-y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Abgebrochen."
  exit 0
fi

echo "🔄 Images aktualisieren..."
$COMPOSE_CMD pull

echo "🛑 Container stoppen..."
$COMPOSE_CMD down

echo "🚀 Container starten..."
$COMPOSE_CMD up -d

echo "✅ Update abgeschlossen!"
