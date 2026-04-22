#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Graphic Studio Tool. Automazione per la creazione di temi 
# icone, modifica colori SVG massiva e ottimizzazione file.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

VERDE='\033[0;32m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
ROSSO='\033[0;31m'
NC='\033[0m'

# --- 🎨 CREAZIONE & TEMPLATE ---
studio_create() {
read -p "Nome nuovo tema: " NAME
NAME=${NAME:-"New-Theme"}
BASE="$HOME/dotfiles/graphics/icons/$NAME"
mkdir -p "$BASE"/{16x16,22x22,24x24,32x32,48x48,64x64,128x128,scalable}/{apps,places,status,devices}
echo "Struttura creata in $BASE"
}

# --- 🛠️ MODIFICA SVG (Colori e Spazi) ---
studio_mod() {
echo -e "1) Cambia Colore HEX  2) Rimuovi Spazi dai nomi  3) Ottimizza (Scour)"
read -p "Scelta: " SUB
case $SUB in
1)
read -p "Vecchio HEX (es. 359bfa): " OLD
read -p "Nuovo HEX: " NEW
find . -type f -name "*.svg" -exec sed -i "s/#${OLD#\#}/#${NEW#\#}/gI" {} +
echo "Colori aggiornati."
;;
2)
find . -type f -name "* *.svg" | while read -r file; do
mv -v "$file" "${file// /}"
done
;;
3)
if command -v scour &> /dev/null; then
find . -name "*.svg" -exec scour -i {} -o {}.tmp --enable-viewboxing --indent=none --quiet \; -exec mv {}.tmp {} \;
echo "Ottimizzazione completata."
else
echo "Installa 'scour' prima."
fi
;;
esac
}

# --- 🔗 SYMLINKER ---
studio_links() {
echo -e "${GIALLO}Creazione link standard (folder -> inode-directory)...${NC}"
ln -sf folder.svg inode-directory.svg
ln -sf folder.svg gnome-fs-directory.svg
echo "Link creati nella cartella attuale."
}

# --- 📦 INSTALLATORE & CACHE ---
studio_install() {
if [ "$EUID" -ne 0 ]; then sudo "$0" install_root; return; fi
}

install_root() {
echo "Aggiornamento cache icone in /usr/share/icons..."
for dir in /usr/share/icons/*; do
if [ -d "$dir" ] && [ -f "$dir/index.theme" ]; then
gtk-update-icon-cache -f -q "$dir"
fi
done
echo "Tutte le cache aggiornate."
}

# --- MENU ---
if [ "$1" == "install_root" ]; then install_root; exit; fi

clear
echo -e "${CYAN}=============================================="
echo -e "      ILNANNY GRAPHIC STUDIO 2026            "
echo -e "==============================================${NC}"
echo "1) [NEW]    Crea Struttura Nuovo Tema"
echo "2) [EDIT]   Modifica (Colori, Spazi, Ottimizzazione)"
echo "3) [LINK]   Genera Symlinks Standard"
echo "4) [CACHE]  Aggiorna Cache Sistema (Root)"
echo "5) Esci"
echo -e "${CYAN}----------------------------------------------${NC}"
read -p "Scegli un'opzione: " OPT

case $OPT in
1) studio_create ;;
2) studio_mod ;;
3) studio_links ;;
4) studio_install ;;
5) exit 0 ;;
esac
