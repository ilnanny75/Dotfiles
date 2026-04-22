#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Arch Installation - Fase 3. Setup Desktop Environment XFCE, 
# Audio (PipeWire), Wi-Fi e Bluetooth (Blueman).
# Modificato: rimosso blueberry, integrato blueman e alsamixer.
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

[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 03-desktop.sh"

VARS_FILE="/tmp/arch-install-vars.env"
[[ -f "${VARS_FILE}" ]] && source "${VARS_FILE}" || MOUNTPOINT="/mnt/arch"

USERNAME="ilnanny"

# ─── 1. XFCE4 e Greeter ──────────────────────────────────────────────────────
info "Installazione XFCE4 e LightDM..."
arch-chroot ${MOUNTPOINT} pacman -S --noconfirm \
    xfce4 xfce4-goodies lightdm lightdm-slick-greeter \
    network-manager-applet volumeicon pavucontrol

# Configurazione LightDM
sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' ${MOUNTPOINT}/etc/lightdm/lightdm.conf
systemctl --root=${MOUNTPOINT} enable lightdm
ok "XFCE e LightDM configurati."

# ─── 2. Audio (PipeWire + Alsa Utils) ────────────────────────────────────────
info "Configurazione Audio (PipeWire)..."
arch-chroot ${MOUNTPOINT} pacman -S --noconfirm \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack \
    wireplumber alsa-utils
ok "Audio configurato (Alsamixer disponibile)."

# ─── 3. Bluetooth (Esclusivo Blueman) ────────────────────────────────────────
info "Configurazione Bluetooth (Blueman)..."
arch-chroot ${MOUNTPOINT} pacman -S --noconfirm bluez bluez-utils blueman
systemctl --root=${MOUNTPOINT} enable bluetooth
ok "Bluetooth abilitato con Blueman."

# ─── 4. Terminale e Font ─────────────────────────────────────────────────────
info "Installazione terminale e font..."
arch-chroot ${MOUNTPOINT} pacman -S --noconfirm \
    xfce4-terminal ttf-dejavu ttf-liberation noto-fonts \
    ttf-font-awesome
ok "Font installati."

# ─── 5. Thunar e File System ─────────────────────────────────────────────────
info "Ottimizzazione Thunar e dischi..."
arch-chroot ${MOUNTPOINT} pacman -S --noconfirm \
    thunar-archive-plugin thunar-volman gvfs gvfs-mtp \
    gvfs-afc ntfs-3g udiskie
ok "Thunar configurato con supporto completo."

# ─── 6. Tema Dark di Base ────────────────────────────────────────────────────
info "Impostazione tema dark..."
USER_HOME="/home/${USERNAME}"
mkdir -p "${MOUNTPOINT}${USER_HOME}/.config/gtk-3.0"
cat > "${MOUNTPOINT}${USER_HOME}/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF
arch-chroot ${MOUNTPOINT} chown -R ${USERNAME}:${USERNAME} ${USER_HOME}/.config
ok "Tema scuro applicato."

echo -e "\n${GREEN}${BOLD}✔ Script 03 completato. Riavvia o procedi con 04-postinstall.sh${RESET}\n"
