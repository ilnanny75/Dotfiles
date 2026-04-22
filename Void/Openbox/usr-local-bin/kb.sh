#!/bin/bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere   = ilnanny
#   Github    : https://github.com/ilnanny75
#================================================
#   Progetto  : Visualizza Scorciatoie Tastiera
#================================================

# Colori
STD='\033[0;0;39m'
LCYAN="\e[1;36m"
YELLOW="\e[1;33m"

clear
echo -e "${LCYAN}╔════════════════════════════════════════════════════╗"
echo -e "║          SCORCIATOIE DA TASTIERA (Void)            ║"
echo -e "╚════════════════════════════════════════════════════╝${STD}\n"

echo -e "${YELLOW}SUPER + Enter${STD}   -> Apri Terminale"
echo -e "${YELLOW}SUPER + D${STD}       -> Apri Menu App (dmenu/rofi)"
echo -e "${YELLOW}SUPER + Q${STD}       -> Chiudi Finestra"
echo -e "${YELLOW}SUPER + X${STD}       -> Menu Logout"
echo -e "${YELLOW}ALT + Tab${STD}       -> Cambia Finestra"

echo -e "\n------------------------------------------------"
echo -e "${LCYAN}Fatto! Premi INVIO per uscire...${STD}"
read -r
