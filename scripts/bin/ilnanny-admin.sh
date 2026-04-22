#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Tool di amministrazione e sviluppo. Gestione boot (Grub), 
# controllo versioni GTK, compilazione C e utility varie.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

VERDE='\033[0;32m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

check_root() {
if [ "$EUID" -ne 0 ]; then
echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
exec sudo "$0" "$@"
fi
}

# --- 🖥️ GESTIONE BOOT (Ex Grub-Master) ---
manage_boot() {
check_root
echo -e "${CYAN}--- Ripristino/Aggiornamento GRUB ---${NC}"
update-grub || grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${VERDE}Configurazione GRUB rigenerata.${NC}"
}

# --- 🛠️ DEVELOPMENT (Ex Compile & GTK-Version) ---
manage_dev() {
echo -e "1) Controlla Versioni GTK  2) Compila sorgente locale"
read -p "Scelta: " DEV_OPT
case $DEV_OPT in
1)
for v in 2 3 4; do
if pkg-config --exists "gtk+-$v.0" 2>/dev/null; then
echo -e "${VERDE}GTK $v:${NC} $(pkg-config --modversion "gtk+-$v.0")"
fi
done
;;
2)
read -p "Inserisci nome file (senza estensione): " FILE
gcc -Wall "$FILE".c -o "$FILE" $(pkg-config --cflags --libs gtk+-3.0)
;;
esac
}

# --- 🎬 MULTIMEDIA (Ex DVD-Convert) ---
manage_media() {
echo -e "${CYAN}--- Conversione Video FFmpeg ---${NC}"
read -p "File sorgente (ISO o MKV): " IN
read -p "Nome file output: " OUT
ffmpeg -i "$IN" -c:v libx264 -crf 20 -c:a aac -b:a 192k "$OUT"
}

# --- 📅 UTILS (Ex Giorno-Corrente) ---
manage_utils() {
read -p "Inserisci data (AAAA-MM-GG): " DATA
date -d "$DATA" +"Il giorno era un: %A"
}

# --- MENU ---
clear
echo -e "${CYAN}=============================================="
echo -e "       ILNANNY ADMIN TOOLBOX 2026            "
echo -e "==============================================${NC}"
echo "1) [BOOT]   Rigenera GRUB"
echo "2) [DEV]    GTK Check & Compile"
echo "3) [MEDIA]  Converti Video (FFmpeg)"
echo "4) [DATE]   Calcola giorno della settimana"
echo "5) [FILE]   Apri Dotfiles in File Manager"
echo "6) Esci"
read -p "Scegli un'opzione: " OPT

case $OPT in
1) manage_boot ;;
2) manage_dev ;;
3) manage_media ;;
4) manage_utils ;;
5) pcmanfm ~/dotfiles/scripts/bin/ & ;;
6) exit 0 ;;
esac
