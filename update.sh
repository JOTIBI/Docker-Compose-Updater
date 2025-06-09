#!/bin/bash

# Docker Compose Updater Script
# Developed and proudly powered by JOTIBI

# ========== DEPENDENCY CHECK ==========
REQUIRED_CMDS=(docker docker-compose)
MISSING=()

for CMD in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$CMD" &>/dev/null; then
    MISSING+=("$CMD")
  fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
  echo "The following required tools are missing: ${MISSING[*]}"
  read -p "Do you want to install them now? (y/n): " INSTALL_CHOICE
  INSTALL_CHOICE=${INSTALL_CHOICE:-n}
  if [[ "$INSTALL_CHOICE" =~ ^[Yy]$ ]]; then
    apt update
    apt install -y "${MISSING[@]}"
  else
    echo "Please install the missing packages and rerun the script."
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
  read -p "Enter the Docker Compose project directory (default: ./): " PROJECT_PATH
  PROJECT_PATH=${PROJECT_PATH:-./}
  if [ -f "$PROJECT_PATH/docker-compose.yml" ]; then
    break
  else
    echo "No docker-compose.yml found in '$PROJECT_PATH'. Try again."
  fi
done

cd "$PROJECT_PATH" || exit 1

# Confirm update
read -p "Proceed to update containers in '$PROJECT_PATH'? (y/n): " CONFIRM
CONFIRM=${CONFIRM:-y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted by user."
  exit 0
fi

echo "Pulling latest images..."
docker compose pull

echo "Stopping containers..."
docker compose down

echo "Starting updated containers..."
docker compose up -d

echo "==== Update completed successfully! ===="
