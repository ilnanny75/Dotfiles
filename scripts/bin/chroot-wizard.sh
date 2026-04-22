#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# 🛠 CHROOT WIZARD: HOLLYWOOD EDITION 2026
# Autore: ilnanny (Modded for style & safety)
# ═══════════════════════════════════════════════════════════════════

# Colori e Stile
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# 1. Funzione Barra di Caricamento (Effetto Wow)
progress_bar() {
    local duration=$1
    local task=$2
    local width=20
    echo -ne "${CYAN}$task... [          ] (0%)\r"
    for i in $(seq 1 $width); do
        sleep $(echo "scale=3; $duration/$width" | bc 2>/dev/null || echo 0.05)
        per=$((i * 100 / width))
        bar=$(printf "%-${width}s" "$(printf '#%.0s' $(seq 1 $i))")
        echo -ne "${CYAN}$task... [$bar] ($per%)\r"
    done
    echo -e "${GREEN}\n[ OK ] $task Completato!${RESET}"
}

# 2. Controllo Privilegi Root (Auto-Sudo)
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Accesso negato. Elevazione privilegi in corso...${RESET}"
    sudo "$0" "$@" || exit 1
    exit 0
fi

# 3. Funzione di Pulizia (Trap)
cleanup() {
    echo -e "\n${RED}--- USCITA RILEVATA: SMONTAGGIO DI EMERGENZA ---${RESET}"
    for mnt in /mnt/boot/efi /mnt/dev/pts /mnt/dev /mnt/proc /mnt/sys /mnt/run /mnt; do
        if mountpoint -q "$mnt"; then
            echo -n "Scollegamento $mnt... "
            umount -l "$mnt" 2>/dev/null && echo "Fatto." || {
                echo "Occupato! Uso fuser..."
                fuser -kvm "$mnt" 2>/dev/null
                sleep 1
                umount -R "$mnt" 2>/dev/null
            }
        fi
    done
    echo -e "${GREEN}✅ Sistema pulito. Alla prossima, Hacker.${RESET}"
}

# Assicura la pulizia anche in caso di interruzione brusca
trap cleanup EXIT

clear
echo -e "${CYAN}"
echo "  ██████╗██╗  ██╗██████╗  ██████╗  ██████╗ ████████╗"
echo " ██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝"
echo " ██║     ███████║██████╔╝██║   ██║██║   ██║   ██║   "
echo " ██║     ██╔══██║██╔══██╗██║   ██║██║   ██║   ██║   "
echo " ╚██████╗██║  ██║██║  ██║╚██████╔╝╚██████╔╝   ██║   "
echo "  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   "
echo -e "${RESET}"
echo -e "${YELLOW}Wizard per Fedora, Debian, Arch e Void Linux${RESET}\n"

# 4. Selezione Device
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
echo ""
read -p "Inserisci il device della ROOT (es. sda2): " ROOT_DEV

if [[ ! -b "/dev/$ROOT_DEV" ]]; then
    echo -e "${RED}ERRORE: Device /dev/$ROOT_DEV non trovato!${RESET}"
    exit 1
fi

# Montaggio Root
mount /dev/"$ROOT_DEV" /mnt || { echo -e "${RED}Impossibile montare ROOT.${RESET}"; exit 1; }
progress_bar 0.5 "Montaggio Root System"

# 5. Gestione EFI
read -p "Hai una partizione EFI separata? (s/n): " HAS_EFI
if [[ $HAS_EFI == "s" ]]; then
    read -p "Inserisci il device EFI (es. sda1): " EFI_DEV
    if [[ -b "/dev/$EFI_DEV" ]]; then
        mkdir -p /mnt/boot/efi
        mount /dev/"$EFI_DEV" /mnt/boot/efi 2>/dev/null || mount /dev/"$EFI_DEV" /mnt/boot
        progress_bar 0.5 "Configurazione Bootloader"
    fi
fi

# 6. Montaggio Bind con Barra Hollywood
echo -e "\n${YELLOW}Preparazione sistemi virtuali...${RESET}"
for i in /dev /dev/pts /proc /sys /run; do
    if mount -B "$i" "/mnt$i"; then
        progress_bar 0.3 "Configurazione $i"
    else
        echo -e "${RED}Errore critico su $i${RESET}"
        exit 1
    fi
done

# Copia DNS
cp -L /etc/resolv.conf /mnt/etc/resolv.conf 2>/dev/null

# 7. Accesso finale
echo -e "\n${GREEN}════════════════════════════════════════════════════════"
echo "  SISTEMA PRONTO: Digita 'exit' per uscire e smontare"
echo -e "════════════════════════════════════════════════════════${RESET}\n"

chroot /mnt /bin/bash
