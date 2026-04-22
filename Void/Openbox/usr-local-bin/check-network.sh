#!/bin/bash
#================================================
#   O.S.      : Gnu Linux
#   Author    : Cristian Pozzessere   = ilnanny
#   Github    : https://github.com/ilnanny75
#================================================
#   Progetto  : Network Status
#================================================

# Colori
STD='\033[0;0;39m'
LCYAN="\e[1;36m"
GREEN='\033[1;32;3m'
RED='\033[0;31m'

clear
echo -e "${LCYAN}Controllando la connessione...${STD}\n"

# Esempio di logica ottimizzata: ping rapido
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}Connessione OK!${STD}"
else
    echo -e "${RED}Sei offline.${STD}"
fi

echo -e "\n------------------------------------------------"
echo -e "${LCYAN}Fatto! Premi INVIO per uscire...${STD}"
read -r
exit 0
