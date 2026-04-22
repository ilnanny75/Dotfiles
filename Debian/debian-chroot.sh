#!/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# DEBIAN MASTER INSTALLER 2026 - Versione SSD Crucial
# Target: Preparazione sistema con Smart Hardware Detection
# 
#  Autore: ilnanny 2026
#  Mail  : ilnannyhack@gmail.com
#  GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# --- COLORI ---
V="\e[32m"; R="\e[31m"; G="\e[33m"; C="\e[36m"; B="\e[1m"; RESET="\e[0m"

# FUNZIONE GESTIONE ERRORI
error_handler() {
    echo -e "\n${R}!!! ERRORE RILEVATO !!!${RESET}"
    read -p "Premi INVIO per uscire..."
}
trap error_handler ERR

# 1. CONTROLLO PRIVILEGI
if [[ $EUID -ne 0 ]]; then
    echo -e "${G}Richiesti privilegi di ROOT.${RESET}"
    exec sudo "$0" "$@"
    exit
fi

# 2. RACCOLTA DATI
clear
echo -e "${B}${C}--- CONFIGURAZIONE DEBIAN PRO (Smart Hardware Detection) ---${RESET}"
read -p "Nome Utente: " NEW_USER
read -s -p "Password Utente: " USER_PASS; echo
read -s -p "Password ROOT: " ROOT_PASS; echo
echo -e "------------------------------------------------------"
echo -e "Ambiente Grafico: 1) XFCE (Consigliato)  2) GNOME"
read -p "Scelta (1-2): " DE_CHOICE

# 3. ANALISI HARDWARE
IS_MATEBOOK=false
[[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) =~ "HUAWEI" ]] && IS_MATEBOOK=true

# 4. GESTIONE DISCHI
echo -e "\n${B}Analisi Dischi:${RESET}"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MODEL | grep -v "loop"
echo "------------------------------------------------------"
read -p "Partizione ROOT (es. sda2): " RAW_ROOT
TARGET_ROOT="/dev/${RAW_ROOT#/dev/}"
read -p "Partizione EFI (es. sda1): " RAW_EFI
TARGET_EFI="/dev/${EFI_ROOT#/dev/}"

# --- AVVISO DI FORMATTAZIONE ---
echo -e "\n${R}${B}!!! ATTENZIONE !!!${RESET}"
echo -e "${R}Stai per FORMATTARE $TARGET_ROOT e $TARGET_EFI${RESET}"
read -p "Tutti i dati andranno persi. Procedere? (s/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then echo "Operazione annullata."; exit 0; fi

# 5. FORMATTAZIONE E MOUNT
echo -e "${V}Formattazione con label Debian-root...${RESET}"
umount -l "$TARGET_ROOT" 2>/dev/null || true
umount -l "$TARGET_EFI" 2>/dev/null || true

mkfs.ext4 -F -L "Debian-root" "$TARGET_ROOT"
mkfs.vfat -F 32 "$TARGET_EFI"
tune2fs -L "Debian-root" "$TARGET_ROOT" # Forza label

MOUNT_DIR="/mnt/debian_pro"
mkdir -p "$MOUNT_DIR"
mount "$TARGET_ROOT" "$MOUNT_DIR"
mkdir -p "$MOUNT_DIR/boot/efi"
mount "$TARGET_EFI" "$MOUNT_DIR/boot/efi"

# 6. DEBOOTSTRAP
apt update && apt install -y debootstrap debian-archive-keyring
echo -e "${V}Installazione base Debian Bookworm...${RESET}"
debootstrap --arch amd64 bookworm "$MOUNT_DIR" http://deb.debian.org/debian/

# 7. SETUP CHROOT
cat <<EOF > "$MOUNT_DIR/setup.sh"
#!/bin/bash
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
apt update
apt install -y linux-image-amd64 firmware-linux firmware-linux-nonfree \\
               firmware-sof-signed firmware-iwlwifi firmware-realtek \\
               alsa-utils pipewire wireplumber blueman network-manager \\
               grub-efi-amd64 efibootmgr os-prober sudo git curl wget

[ "$IS_MATEBOOK" = true ] && echo "options snd-intel-dspcfg dsp_driver=3" > /etc/modprobe.d/huawei.conf

if [ "$DE_CHOICE" == "1" ]; then
    apt install -y xfce4 xfce4-goodies lightdm
    systemctl enable lightdm
else
    apt install -y gnome-core gdm3
    systemctl enable gdm3
fi

useradd -m -G sudo -s /bin/bash $NEW_USER
echo "$NEW_USER:$USER_PASS" | chpasswd
echo "root:$ROOT_PASS" | chpasswd

grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
exit
EOF

# ESECUZIONE
chmod +x "$MOUNT_DIR/setup.sh"
for d in dev dev/pts proc sys run; do mount --bind "/$d" "$MOUNT_DIR/$d"; done
chroot "$MOUNT_DIR" /bin/bash -c "export IS_MATEBOOK=$IS_MATEBOOK; /setup.sh"

# 8. DOTFILES
clear
read -p "Vuoi integrare i dotfiles da GitHub? (s/n): " DOT_ANS
if [[ "$DOT_ANS" =~ ^[Ss]$ ]]; then
    chroot "$MOUNT_DIR" /bin/bash -c "cd /home/$NEW_USER && git clone https://github.com/ilnanny75/dotfiles dotfiles && chown -R $NEW_USER:$NEW_USER dotfiles"
fi

# 9. FINE
genfstab -U "$MOUNT_DIR" >> "$MOUNT_DIR/etc/fstab"
umount -R "$MOUNT_DIR"
echo -e "\n${V}FINITO! Riavvia e scollega la chiavetta.${RESET}"
