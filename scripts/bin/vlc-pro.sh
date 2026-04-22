#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: VLC & Qt Theme Helper. Installa VLC e configura l'integrazione 
# estetica Qt5/6 Include il download automatico delle skin 
# personalizzate .
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- 🎨 Colori ---
green='\e[0;32m'
blue='\e[0;34m'
cyan='\e[0;36m'
yellow='\e[1;33m'
red='\e[0;31m'
nc='\e[0m'

echo -e "${blue}==========================================================${nc}"
echo -e "${cyan}   VLC & Qt Theme Helper v2.0 - Lab 2026${nc}"
echo -e "${blue}==========================================================${nc}"

# 1. Rilevamento Distribuzione e Installazione
PKGS="vlc qt5ct qt6ct papirus-icon-theme wget"

if [ -f /etc/arch-release ]; then
    DISTRO="Arch Linux"
    install_pkgs() { sudo pacman -S --needed $PKGS; }
elif [ -f /etc/debian_version ]; then
    DISTRO="Debian/Ubuntu"
    install_pkgs() { sudo apt update && sudo apt install -y $PKGS; }
elif [ -f /etc/void-release ]; then
    DISTRO="Void Linux"
    install_pkgs() { sudo xbps-install -S $PKGS; }
else
    DISTRO="Sconosciuta"
    install_pkgs() { echo -e "${red}[✘] Distribuzione non supportata.${nc}"; }
fi

echo -e "${green}[✔] Sistema rilevato:${nc} $DISTRO"
read -p "Vuoi controllare/installare i pacchetti necessari? (s/n): " inst_pkg
[[ $inst_pkg == [sS] ]] && install_pkgs

# 2. Controllo Variabili d'Ambiente (La parte che ti serviva)
echo -e "\n${blue}--- 🔍 Controllo Variabili di Sessione ---${nc}"
VAR_NAME="QT_QPA_PLATFORMTHEME"
VAR_VAL="qt5ct"
FILES_TO_CHECK=("$HOME/.profile" "$HOME/.xprofile" "/etc/environment")

for FILE in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$FILE" ]; then
        if grep -q "$VAR_NAME" "$FILE"; then
            echo -e "${green}[✔] Trovata in $FILE${nc}"
        else
            echo -e "${yellow}[!] Mancante in $FILE${nc}"
            read -p "Vuoi aggiungerla a $FILE? (s/n): " add_var
            if [[ $add_var == [sS] ]]; then
                # Se è /etc/environment, serve sudo e non serve 'export'
                if [[ "$FILE" == "/etc/environment" ]]; then
                    echo "$VAR_NAME=$VAR_VAL" | sudo tee -a "$FILE" > /dev/null
                else
                    echo "export $VAR_NAME=$VAR_VAL" >> "$FILE"
                fi
                echo -e "${green}    Aggiunta con successo!${nc}"
            fi
        fi
    else
        echo -e "${cyan}[i] Il file $FILE non esiste, lo salto.${nc}"
    fi
done

# 3. Download Skin VLC (.vlt)
echo -e "\n${blue}--- 🎬 Skin VLC (.vlt) ---${nc}"
read -p "Vuoi scaricare le skin Arch e Papirus per VLC? (s/n): " dl_skin
if [[ $dl_skin == [sS] ]]; then
    SKIN_DIR="$HOME/.local/share/vlc/skins2"
    mkdir -p "$SKIN_DIR"
    wget -O "$SKIN_DIR/Arch-Dark.vlt" https://github.com/vlc-skins/arch-dark/raw/master/Arch-Dark.vlt 2>/dev/null
    wget -O "$SKIN_DIR/Papirus.vlt" https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-vlc-skin/master/Papirus.vlt 2>/dev/null
    echo -e "${green}[✔] Skin salvate in $SKIN_DIR${nc}"
fi

echo -e "\n${blue}==========================================================${nc}"
echo -e "${green}Operazione completata! Se hai aggiunto variabili, riavvia.${nc}"
