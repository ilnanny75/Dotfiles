#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Hardware Manager. Gestione display (xrandr), registrazione 
# schermo (ffmpeg), test audio e riavvio interfacce di rete.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

VERDE='\033[0;32m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- 🖥️ DISPLAY (Ex Schermo) ---
manage_display() {
echo -e "1) Solo Laptop  2) Solo Esterno (HDMI)  3) Duplica"
read -p "Opzione: " DSP
case $DSP in
1) xrandr --output eDP-1 --auto --output HDMI-1 --off ;;
2) xrandr --output eDP-1 --off --output HDMI-1 --auto ;;
3) xrandr --output eDP-1 --auto --output HDMI-1 --auto --same-as eDP-1 ;;
esac
}

# --- 🎥 SCREENCAST (Ex Screencast) ---
manage_record() {
FILE="scast_$(date +%Y%m%d_%H%M%S).mp4"
echo -e "${GIALLO}Registrazione avviata... Premi 'q' nel terminale per fermare.${NC}"
ffmpeg -f x11grab -video_size 1920x1080 -i :0.0 -c:v libx264 -preset ultrafast "$HOME/Video/$FILE"
}

# --- 🔊 AUDIO TEST (Ex Speaker-test & Volume) ---
manage_audio() {
echo -e "1) Test Speaker (L/R)  2) Reset Alsa/Pulse"
read -p "Opzione: " AUD
case $AUD in
1) speaker-test -t wav -c 2 ;;
2) pulseaudio -k && alsa force-reload ;;
esac
}

# --- 🌐 NETWORK (Ex wlan0) ---
manage_net() {
echo -e "${CYAN}--- Stato Interfacce ---${NC}"
ip -brief link
echo -e "\n${GIALLO}Riavvio Wi-Fi...${NC}"
nmcli networking off && nmcli networking on
}

# --- MENU ---
clear
echo -e "${CYAN}=============================================="
echo -e "      ILNANNY HARDWARE CENTER 2026           "
echo -e "==============================================${NC}"
echo "1) [DISPLAY] Gestione Monitor (xrandr)"
echo "2) [RECORD]  Registra Schermo (ffmpeg)"
echo "3) [AUDIO]   Test & Reset Audio"
echo "4) [WIFI]    Stato & Reset Rete"
echo "5) Esci"
read -p "Scegli un'opzione: " OPT

case $OPT in
1) manage_display ;;
2) manage_record ;;
3) manage_audio ;;
4) manage_net ;;
5) exit 0 ;;
esac
