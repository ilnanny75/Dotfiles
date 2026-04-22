#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# MateBook Audio Fixer - ES8336 & SOF Firmware (REVISIONE FEDORA 43)
# ═══════════════════════════════════════════════════════════════════

VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Forza privilegi di root per l'installazione, ma non per PipeWire
if [ "$EUID" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

detect_distro() {
    if [ -f /etc/void-release ]; then DISTRO="void"
    elif [ -f /etc/arch-release ]; then DISTRO="arch"
    elif [ -f /etc/debian_version ]; then DISTRO="debian"
    elif [ -f /etc/fedora-release ]; then DISTRO="fedora"
    else DISTRO="unknown"; fi
}

# Funzione per sbloccare l'audio (La logica del tuo PC)
unmute_logic() {
    echo -e "${GIALLO}Sblocco canali audio (Fix Paradosso Matebook)...${NC}"
    
    # 1. Configurazione ALSA (La tua configurazione vincente)
    # Speaker DEVE essere Mute per sentire l'audio sul tuo chip
    amixer -c 0 -q set Speaker mute 2>/dev/null
    # Headphone DEVE essere Unmute
    amixer -c 0 -q set Headphone unmute 2>/dev/null
    amixer -c 0 -q set Headphone 75% 2>/dev/null
    # Sveglia hardware
    amixer -c 0 -q cset numid=29 on 2>/dev/null
    
    # 2. Configurazione PipeWire (Per impostare il Default senza farlo a mano)
    # Cerchiamo l'utente reale per dare comandi a PipeWire (che non gira come root)
    REAL_USER=$(logname)
    sudo -u "$REAL_USER" bash -c '
        NODE_ID=$(wpctl status | grep "Speakers" | sed "s/[^0-9]*\([0-9]\+\).*/\1/" | head -n 1)
        if [ ! -z "$NODE_ID" ]; then
            wpctl set-default $NODE_ID
            wpctl set-mute $NODE_ID 0
            wpctl set-volume $NODE_ID 0.65
        fi
    '
}

fix_audio() {
    detect_distro
    echo -e "${CYAN}--- Installazione Firmware ($DISTRO) ---${NC}"

    case $DISTRO in
        void) xbps-install -Sy sof-firmware alsa-utils ;;
        arch) pacman -Sy --needed sof-firmware alsa-utils ;;
        debian) apt update && apt install -y firmware-sof-signed alsa-utils ;;
        fedora) dnf install -y alsa-sof-firmware alsa-utils ;;
    esac

    # Applicazione Quirk (0x02 spesso è meglio di 0x01 per Comet Lake)
    echo "options snd_soc_sof_8336 quirk=0x02" > /etc/modprobe.d/es8336.conf
    
    if [ "$DISTRO" == "void" ]; then dracut --force
    elif [ "$DISTRO" == "arch" ]; then mkinitcpio -P
    elif [ "$DISTRO" == "fedora" ]; then dracut --force
    fi

    unmute_logic
    echo -e "${VERDE}Fix completato! Riavvia per applicare i moduli kernel.${NC}"
    read -rp "Premi Invio per continuare..."
}

# Menu
while true; do
    clear
    echo -e "${CYAN}=============================================="
    echo -e "      MATEBOOK AUDIO MANAGER - Revisionato     "
    echo -e "==============================================${NC}"
    echo "1) Esegui Fix Completo (Firmware + Kernel + Unmute)"
    echo "2) Solo Unmute Canali (Configurazione Vincente)"
    echo "3) Esci"
    read -rp "Scegli: " OPT

    case $OPT in
        1) fix_audio ;;
        2) unmute_logic
           echo -e "${VERDE}Configurazione applicata!${NC}"
           sleep 2 ;;
        3) exit 0 ;;
    esac
done