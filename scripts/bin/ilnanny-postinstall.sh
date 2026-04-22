#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#  ilnanny POST-INSTALL MANAGER  v3.1
#  Script master: Arch, Debian/MX, Void e FEDORA (DNF5 Ready)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── COLORI E STILE ──────────────────────────────────────────────────────────
RESET="\033[0m"; BOLD="\033[1m"; DIM="\033[2m"
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"
MAGENTA="\033[35m"; CYAN="\033[36m"

# ── VARIABILI E LOG ─────────────────────────────────────────────────────────
VERSION="3.1"
LOG_FILE="$HOME/postinstall.log"

# ── FUNZIONI LOG ────────────────────────────────────────────────────────────
info() { echo -e "${CYAN}${BOLD}󰋼 INFO:${RESET} $1"; }
ok()   { echo -e "${GREEN}${BOLD}󰄬 OK:${RESET} $1"; }
warn() { echo -e "${YELLOW}${BOLD}󰅚 WARN:${RESET} $1"; }

pausa() {
    echo -e "\n${DIM}Premi INVIO per tornare al menu...${RESET}"
    read -r
}

# ── RILEVAMENTO DISTRO ──────────────────────────────────────────────────────
rileva_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
    
    case "$DISTRO" in
        arch)   PM="pacman -S --noconfirm" ; UPDATE="sudo pacman -Sy" ;;
        debian|mx) PM="apt install -y"     ; UPDATE="sudo apt update" ;;
        void)   PM="xbps-install -Sy"      ; UPDATE="sudo xbps-install -S" ;;
        fedora) PM="dnf install -y"        ; UPDATE="sudo dnf check-update || true" ;;
        *) echo -e "${RED}Distro non supportata!${RESET}"; exit 1 ;;
    esac
}

# ── ANTEPRIMA PACCHETTI ─────────────────────────────────────────────────────
mostra_anteprima() {
    local sezione="$1"
    local lista="$2"
    echo -e "\n${CYAN}${BOLD}📦 ANALISI SEZIONE: $sezione${RESET}"
    echo -e "${DIM}Pacchetti pronti per il deploy:${RESET}"
    echo -e "${YELLOW}$lista${RESET}\n"
    
    echo -en "${MAGENTA}${BOLD}⚡ Procedere con l'installazione su ${DISTRO^^}? [s/N]: ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]] || return 1
}

# ── SEZIONI SOFTWARE (ESEMPI MAPPATI) ───────────────────────────────────────
sezione_sistema() {
    local pkgs=""
    case "$DISTRO" in
        fedora) pkgs="git curl wget neovim htop util-linux-user" ;;
        debian) pkgs="build-essential git curl wget neovim htop" ;;
        arch)   pkgs="base-devel git curl wget neovim htop" ;;
        void)   pkgs="base-devel git curl wget neovim htop" ;;
    esac
    if mostra_anteprima "SISTEMA BASE" "$pkgs"; then sudo $PM $pkgs; fi
}

sezione_grafica() {
    local pkgs=""
    case "$DISTRO" in
        fedora) pkgs="gimp inkscape vlc blender" ;;
        debian) pkgs="gimp inkscape vlc" ;;
        arch)   pkgs="gimp inkscape vlc" ;;
        void)   pkgs="gimp inkscape vlc" ;;
    esac
    if mostra_anteprima "GRAFICA & MULTIMEDIA" "$pkgs"; then sudo $PM $pkgs; fi
}

sezione_gaming() {
    local pkgs=""
    case "$DISTRO" in
        fedora) pkgs="steam lutris mangohud goverlay" ;;
        debian) pkgs="steam-installer lutris" ;;
        arch)   pkgs="steam lutris mangohud" ;;
        void)   pkgs="steam lutris" ;;
    esac
    if mostra_anteprima "GAMING" "$pkgs"; then sudo $PM $pkgs; fi
}

sezione_shell() {
    local pkgs=""
    case "$DISTRO" in
        fedora) pkgs="zsh fzf ripgrep tldr bitwarden-cli" ;;
        debian) pkgs="zsh fzf ripgrep tldr" ;;
        arch)   pkgs="zsh fzf ripgrep tldr" ;;
        void)   pkgs="zsh fzf ripgrep tldr" ;;
    esac
    if mostra_anteprima "SHELL & SECURITY" "$pkgs"; then sudo $PM $pkgs; fi
}

# ── MENU PRINCIPALE ─────────────────────────────────────────────────────────
menu() {
    while true; do
        clear
        echo -e "${CYAN}═════════════════════════════════════════════════════${RESET}"
        echo -e "${BOLD}${GREEN}    󰊠  POST-INSTALL MANAGER v$VERSION - [${DISTRO^^}]${RESET}"
        echo -e "${CYAN}═════════════════════════════════════════════════════${RESET}"
        echo -e "  1) 🖥️  Sistema Base"
        echo -e "  2) 🎨 Grafica & Multimedia"
        echo -e "  3) 🎮 Gaming"
        echo -e "  4) 🐚 Shell & Sicurezza (CLI)"
        echo -e "  a) 🔄 Aggiorna Sistema"
        echo -e "  q) 󰈆 Esci"
        echo -en "\n${CYAN}${BOLD}Scelta: ${RESET}"
        read -r opt

        case $opt in
            1) sezione_sistema ; pausa ;;
            2) sezione_grafica ; pausa ;;
            3) sezione_gaming  ; pausa ;;
            4) sezione_shell    ; pausa ;;
            a|A) $UPDATE       ; pausa ;;
            q|Q) echo -e "\n${GREEN}Arrivederci!${RESET}\n"; exit 0 ;;
            *) warn "Opzione non valida."; sleep 1 ;;
        esac
    done
}

# ── ENTRYPOINT ─────────────────────────────────────────────────────────────
rileva_distro
menu
