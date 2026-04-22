#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Arch Installation - Fase 4. Script interattivo per software 
# extra (VLC, GIMP, Office) e configurazione alias finali.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }
section() { echo -e "\n${BOLD}${YELLOW}══ $* ══${RESET}"; }

ask() {
    # ask "Descrizione" "pkgs..." → ritorna 0 se confermato
    local desc="$1"; shift
    read -rp "  Installare ${desc}? [s/N] " _ans
    [[ "${_ans,,}" == "s" ]]
}

[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 04-postinstall.sh"

VARS_FILE="/tmp/arch-install-vars.env"
[[ -f "${VARS_FILE}" ]] && source "${VARS_FILE}" || MOUNTPOINT="/mnt/arch"
USERNAME="ilnanny"

mountpoint -q "${MOUNTPOINT}" || error "${MOUNTPOINT} non montato."

echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        ARCH LINUX INSTALL — 04 POST-INSTALL             ║"
echo "║   Software aggiuntivo interattivo | yay | ilnanny       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo "Risponde 's' per installare ogni categoria, 'N' per saltare."
echo ""

# ─── Raccolta scelte utente (fuori da chroot) ─────────────────────────────────

declare -a PACMAN_PKGS=()
declare -a AUR_PKGS=()
declare -a PIP_PKGS=()

# ── Multimedia ────────────────────────────────────────────────────────────────
section "MULTIMEDIA"

ask "VLC (player video/audio universale)" && PACMAN_PKGS+=(vlc)
ask "MPV (player minimalista, GPU decode)" && PACMAN_PKGS+=(mpv)
ask "Celluloid (frontend GTK per MPV)" && PACMAN_PKGS+=(celluloid)
ask "Audacity (editor audio)" && PACMAN_PKGS+=(audacity)
ask "Handbrake (transcodifica video)" && PACMAN_PKGS+=(handbrake)
ask "MKVToolNix (gestione file MKV)" && PACMAN_PKGS+=(mkvtoolnix-gui)
ask "FFmpeg (conversione multimedia CLI)" && PACMAN_PKGS+=(ffmpeg)

# ── Grafica ───────────────────────────────────────────────────────────────────
section "GRAFICA"

ask "GIMP (editor immagini avanzato)" && PACMAN_PKGS+=(gimp)
ask "Inkscape (grafica vettoriale SVG)" && PACMAN_PKGS+=(inkscape)
ask "Krita (pittura digitale)" && PACMAN_PKGS+=(krita)
ask "Darktable (fotoritocco RAW)" && PACMAN_PKGS+=(darktable)
ask "Shotwell (gestore foto)" && PACMAN_PKGS+=(shotwell)
ask "Scribus (desktop publishing)" && PACMAN_PKGS+=(scribus)
ask "ImageMagick (elaborazione immagini CLI)" && PACMAN_PKGS+=(imagemagick)

# ── Office & Documenti ────────────────────────────────────────────────────────
section "OFFICE E DOCUMENTI"

ask "LibreOffice (suite completa - italiano)" && \
    PACMAN_PKGS+=(libreoffice-fresh libreoffice-fresh-it)
ask "Okular (PDF viewer, annotazioni)" && PACMAN_PKGS+=(okular)
ask "Evince (PDF viewer leggero)" && PACMAN_PKGS+=(evince)
ask "Zathura (PDF/EPUB viewer keyboard-driven)" && \
    PACMAN_PKGS+=(zathura zathura-pdf-mupdf)
ask "Calibre (gestore eBook)" && PACMAN_PKGS+=(calibre)
ask "Pandoc (conversione documenti)" && PACMAN_PKGS+=(pandoc)

# ── Browser ───────────────────────────────────────────────────────────────────
section "BROWSER WEB"

ask "Firefox (browser Mozilla)" && PACMAN_PKGS+=(firefox firefox-i18n-it)
ask "Chromium (browser Google open source)" && PACMAN_PKGS+=(chromium)
ask "Brave (privacy browser)" && AUR_PKGS+=(brave-bin)
ask "qutebrowser (browser keyboard-driven)" && PACMAN_PKGS+=(qutebrowser)

# ── Sviluppo ──────────────────────────────────────────────────────────────────
section "SVILUPPO"

ask "VS Code (editor Microsoft — OSS)" && AUR_PKGS+=(visual-studio-code-bin)
ask "Geany (editor leggero, con plugin)" && \
    PACMAN_PKGS+=(geany geany-plugins)
ask "Android Studio (IDE Android)" && AUR_PKGS+=(android-studio)
ask "Android SDK Tools (adb, fastboot)" && \
    PACMAN_PKGS+=(android-tools android-udev)
ask "Git GUI (gitg + gitk)" && \
    PACMAN_PKGS+=(gitg tk)
ask "Docker (containerizzazione)" && \
    PACMAN_PKGS+=(docker docker-compose)
ask "Python pip + virtualenv" && \
    PACMAN_PKGS+=(python-pip python-virtualenv)
ask "Node.js + npm" && \
    PACMAN_PKGS+=(nodejs npm)
ask "Meld (diff visuale)" && PACMAN_PKGS+=(meld)
ask "DBeaver (database GUI)" && AUR_PKGS+=(dbeaver)

# ── Rete & Sicurezza ──────────────────────────────────────────────────────────
section "RETE E SICUREZZA"

ask "Filezilla (FTP/SFTP client)" && PACMAN_PKGS+=(filezilla)
ask "Wireshark (analisi pacchetti)" && \
    PACMAN_PKGS+=(wireshark-qt)
ask "nmap (scanner di rete)" && PACMAN_PKGS+=(nmap)
ask "KeePassXC (gestore password)" && PACMAN_PKGS+=(keepassxc)
ask "Bitwarden (gestore password cloud)" && AUR_PKGS+=(bitwarden-bin)
ask "OpenVPN (client VPN)" && PACMAN_PKGS+=(openvpn networkmanager-openvpn)
ask "Syncthing (sync file P2P)" && PACMAN_PKGS+=(syncthing)

# ── Comunicazione ─────────────────────────────────────────────────────────────
section "COMUNICAZIONE"

ask "Thunderbird (email client)" && PACMAN_PKGS+=(thunderbird thunderbird-i18n-it)
ask "Telegram Desktop" && PACMAN_PKGS+=(telegram-desktop)
ask "Discord" && AUR_PKGS+=(discord)
ask "Signal Desktop" && AUR_PKGS+=(signal-desktop)
ask "Element (Matrix/chat E2E)" && AUR_PKGS+=(element-desktop)

# ── Utilità di sistema ────────────────────────────────────────────────────────
section "UTILITÀ DI SISTEMA"

ask "Timeshift (backup/snapshot)" && AUR_PKGS+=(timeshift)
ask "BleachBit (pulizia disco)" && PACMAN_PKGS+=(bleachbit)
ask "GParted (gestore partizioni)" && PACMAN_PKGS+=(gparted)
ask "Ventoy (USB multiboot)" && AUR_PKGS+=(ventoy-bin)
ask "Neofetch (info sistema in terminale)" && PACMAN_PKGS+=(neofetch)
ask "Btop (monitor risorse avanzato)" && PACMAN_PKGS+=(btop)
ask "Bat (cat con syntax highlight)" && PACMAN_PKGS+=(bat)
ask "Eza (ls moderno)" && PACMAN_PKGS+=(eza)
ask "Fzf (fuzzy finder)" && PACMAN_PKGS+=(fzf)
ask "Ripgrep (grep veloce)" && PACMAN_PKGS+=(ripgrep)
ask "Xclip (clipboard CLI)" && PACMAN_PKGS+=(xclip)
ask "Redshift (filtro luce blu)" && PACMAN_PKGS+=(redshift)

# ── Giochi & Steam ────────────────────────────────────────────────────────────
section "GIOCHI"

ask "Steam (piattaforma gaming)" && {
    # Abilita multilib prima
    sed -i '/\[multilib\]/{n;s/^#Include/Include/}' /etc/pacman.conf
    PACMAN_PKGS+=(steam)
}
ask "Lutris (launcher giochi Linux/Wine)" && PACMAN_PKGS+=(lutris)
ask "Wine (compatibilità Windows)" && \
    PACMAN_PKGS+=(wine wine-mono wine-gecko winetricks)

# ─── Riepilogo scelte ─────────────────────────────────────────────────────────
echo ""
section "RIEPILOGO INSTALLAZIONE"
if [[ ${#PACMAN_PKGS[@]} -gt 0 ]]; then
    echo -e "${CYAN}Pacman:${RESET} ${PACMAN_PKGS[*]}"
fi
if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
    echo -e "${CYAN}AUR (yay):${RESET} ${AUR_PKGS[*]}"
fi
echo ""
read -rp "Confermi l'installazione? [s/N] " CONFIRM
[[ "${CONFIRM,,}" != "s" ]] && { warn "Installazione annullata."; exit 0; }

# ─── Installazione in chroot ──────────────────────────────────────────────────
PACMAN_LIST="${PACMAN_PKGS[*]:-}"
AUR_LIST="${AUR_PKGS[*]:-}"

arch-chroot "${MOUNTPOINT}" /bin/bash <<CHROOT_EOF
set -euo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'
info() { echo -e "\${CYAN}[INFO]\${RESET} \$*"; }
ok()   { echo -e "\${GREEN}[OK]\${RESET}   \$*"; }

USERNAME="${USERNAME}"
PACMAN_LIST="${PACMAN_LIST}"
AUR_LIST="${AUR_LIST}"

# Pacman packages
if [[ -n "\${PACMAN_LIST}" ]]; then
    info "Installazione pacchetti pacman..."
    pacman -Syu --noconfirm
    # shellcheck disable=SC2086
    pacman -S --noconfirm --needed \${PACMAN_LIST}
    ok "Pacchetti pacman installati."
fi

# AUR packages via yay
if [[ -n "\${AUR_LIST}" ]]; then
    info "Installazione pacchetti AUR con yay..."
    # shellcheck disable=SC2086
    sudo -u \${USERNAME} yay -S --noconfirm --needed \${AUR_LIST}
    ok "Pacchetti AUR installati."
fi

# Docker post-setup
if pacman -Q docker &>/dev/null; then
    info "Configurazione Docker..."
    systemctl enable docker
    usermod -aG docker \${USERNAME}
    ok "Docker abilitato e \${USERNAME} aggiunto al gruppo docker."
fi

# Wireshark — aggiungi utente al gruppo
if pacman -Q wireshark-qt &>/dev/null; then
    usermod -aG wireshark \${USERNAME}
    ok "\${USERNAME} aggiunto al gruppo wireshark."
fi

# Syncthing — abilita servizio utente
if pacman -Q syncthing &>/dev/null; then
    systemctl enable syncthing@\${USERNAME}
    ok "Syncthing abilitato per \${USERNAME}."
fi

# Applicazione dotfiles (se clonati nel passo 02)
DOTFILES_DIR="/home/\${USERNAME}/.dotfiles"
if [[ -d "\${DOTFILES_DIR}" ]]; then
    info "Trovati dotfiles in \${DOTFILES_DIR}."
    echo -e "\${YELLOW}[INFO]\${RESET} Applica manualmente i dotfiles dopo il reboot:"
    echo "  cd ~/.dotfiles && bash install.sh"
fi

# Alias utili in .bashrc
BASHRC="/home/\${USERNAME}/.bashrc"
if ! grep -q "## arch-install aliases" "\${BASHRC}" 2>/dev/null; then
    cat >> "\${BASHRC}" <<'BASH_ALIAS'

## arch-install aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat='bat --style=auto'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu && yay -Syu'
alias orphans='pacman -Qtdq | sudo pacman -Rns -'
alias neofetch='neofetch'
BASH_ALIAS
    chown \${USERNAME}:\${USERNAME} "\${BASHRC}"
    ok "Alias aggiunti a .bashrc di \${USERNAME}."
fi

echo ""
echo -e "\${GREEN}\${BOLD}✔ Script 04 post-install completato.\${RESET}"
echo ""
echo -e "\${BOLD}Prossimi passi:${RESET}"
echo "  1. Smonta e riavvia:  umount -R /mnt/arch && reboot"
echo "  2. Seleziona Arch Linux da GRUB"
echo "  3. Login come \${USERNAME} e applica i dotfiles"
echo "  4. Verifica WiFi:    nmtui"
echo "  5. Verifica audio:   pactl info"
CHROOT_EOF

echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   ✔  INSTALLAZIONE ARCH LINUX COMPLETATA!               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "Per smontare e riavviare:"
echo -e "  ${CYAN}umount -R ${MOUNTPOINT} && reboot${RESET}"
echo ""
