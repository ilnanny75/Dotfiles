#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Arch Installation - Fase 2. Pacstrap del sistema base, 
# configurazione locale, utente, sudo e driver Intel TearFree.
# Aggiunto: alsa-utils per alsamixer.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()  { echo -e "${CYAN}[INFO]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error() { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 02-base.sh"

VARS_FILE="/tmp/arch-install-vars.env"
if [[ -f "${VARS_FILE}" ]]; then
    source "${VARS_FILE}"
else
    error "File variabili non trovato in /tmp. Esegui prima lo script 01."
fi

# ─── 1. Pacstrap (Base + Audio Utils) ────────────────────────────────────────
info "Installazione sistema base e pacchetti essenziali..."
pacstrap /mnt/arch base base-devel linux linux-firmware \
    intel-ucode nano bash-completion networkmanager \
    git sudo xfsprogs alsa-utils

# ─── 2. Fstab ────────────────────────────────────────────────────────────────
info "Generazione fstab..."
genfstab -U /mnt/arch >> /mnt/arch/etc/fstab
ok "fstab generato."

# ─── 3. Chroot Setup ─────────────────────────────────────────────────────────
info "Configurazione interna al sistema (via chroot)..."
arch-chroot /mnt/arch /bin/bash <<EOF
set -e

# Locale e Timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=it_IT.UTF-8" > /etc/locale.conf
echo "KEYMAP=it" > /etc/vconsole.conf

# Hostname
echo "arch-matebook" > /etc/hostname

# Password Root
echo "root:ilnanny" | chpasswd

# Utente
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:ilnanny" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Servizi
systemctl enable NetworkManager

EOF
ok "Sistema base configurato."

# ─── 4. Driver Video & Input ─────────────────────────────────────────────────
info "Configurazione Driver Video e Input..."
arch-chroot /mnt/arch pacman -S --noconfirm xf86-video-intel xorg-server libinput

# Configurazione Intel TearFree
mkdir -p /mnt/arch/etc/X11/xorg.conf.d/
cat > /mnt/arch/etc/X11/xorg.conf.d/20-intel.conf <<EOF
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree"    "true"
    Option      "AccelMethod" "sna"
    Option      "DRI"         "3"
EndSection
EOF

# Touchpad libinput
cat > /mnt/arch/etc/X11/xorg.conf.d/40-libinput.conf <<EOF
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
EndSection
EOF
ok "Driver configurati correttamente."

# ─── 5. Installazione Bootloader (GRUB) ──────────────────────────────────────
info "Installazione GRUB su EFI..."
arch-chroot /mnt/arch pacman -S --noconfirm grub efibootmgr
arch-chroot /mnt/arch grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
arch-chroot /mnt/arch grub-mkconfig -o /boot/grub/grub.cfg
ok "Bootloader installato."

echo -e "\n${GREEN}${BOLD}✔ Script 02 completato. Procedi con 03-desktop.sh${RESET}\n"
