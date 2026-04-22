#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota:MateBook Audio Fix - Versione Definitiva per Void Linux
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo -e "${CYAN}Applicazione fix profondo per Void Linux...${NC}"

# 1. Installazione pacchetti necessari
xbps-install -Sy sof-firmware alsa-ucm-conf alsa-utils alsa-plugins-pulseaudio

# 2. Blacklist dei driver che creano conflitto
# Questo impedisce a HDA Intel PCH di apparire in alsamixer
echo -e "${GIALLO}Disabilitando driver in conflitto...${NC}"
cat <<EOF > /etc/modprobe.d/blacklist-matebook.conf
blacklist snd_hda_intel
blacklist snd_soc_avs
blacklist snd_soc_es8316
EOF

# 3. Forzatura Driver SOF e Quirk
# dsp_driver=3 forza l'uso del Sound Open Firmware per ES8336
echo -e "${GIALLO}Configurazione parametri SOF...${NC}"
cat <<EOF > /etc/modprobe.d/matebook-audio.conf
options snd_intel_dspcfg dsp_driver=3
options snd_soc_sof_8336 quirk=0x01
EOF

# 4. Caricamento forzato dei moduli all'avvio
echo "snd_soc_sof_es8336" > /etc/modules-load.d/matebook-audio.conf

# 5. RIGENERAZIONE INITRAMFS (Fondamentale su Void)
# Senza questo, la blacklist non viene letta all'avvio
echo -e "${CYAN}Rigenerazione initramfs con dracut (Attendere...)${NC}"
depmod -a
dracut -f --regenerate-all

# 6. Aggiunta utente al gruppo audio
current_user=$(logname)
usermod -aG audio "$current_user"

# Forza l'unmute dei canali principali per il chip Everest del MateBook
amixer -q set Master unmute
amixer -q set Speaker unmute
amixer -q set Headphone unmute

echo -e "${VERDE}====================================================${NC}"
echo -e "${VERDE}PROCEDURA COMPLETATA. ORA RIAVVIA IL PC.${NC}"
echo -e "${GIALLO}Al riavvio, apri alsamixer, premi F6 e seleziona SOF.${NC}"
echo -e "${VERDE}====================================================${NC}"
