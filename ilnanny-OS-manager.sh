#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Master Setup Script per la gestione e automazione dei 
# dotfiles, installare dipendenze su Void, Arch, Debian e Fedora.
#
# Versione: 2.6 
# Autore  : ilnanny 2026
# ═══════════════════════════════════════════════════════════════════

shopt -s nullglob

# ── Colori ──────────────────────────────────────────────────────────
V="\e[32m"; R="\e[31m"; C="\e[36m"; G="\e[33m"; B="\e[1m"; RESET="\e[0m"

# ── Rilevamento automatico dotfiles 
_trova_dotfiles() {
    local candidati=(
        "${DOTFILES}"
        "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        /media/ilnanny/dati-linux/dotfiles
        "$HOME/dotfiles"
    )
    for p in "${candidati[@]}"; do
        [[ -z "$p" ]] && continue
        if [[ -d "$p/.git" ]]; then
            DOTFILES="$p"
            export DOTFILES
            # Fix SELinux per Fedora
            if [[ "$OS_ID" == "fedora" ]]; then
                sudo chcon -R -t user_home_t "$p" 2>/dev/null || true
            fi
            return 0
        fi
    done
    return 1
}

OS_ID=$(grep -w "^ID" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
OS_ID="${OS_ID:-unknown}"

if ! _trova_dotfiles; then
    echo -e "${R}Errore: Cartella dotfiles non trovata!${RESET}"
    exit 1
fi

# ── Funzioni Log 
info()    { echo -e "${C}󰋼 ${B}INFO:${RESET} $1"; }
warn()    { echo -e "${G}󰀦 ${B}WARN:${RESET} $1"; }
err()     { echo -e "${R}󰅚 ${B}ERRORE:${RESET} $1"; }
ok()      { echo -e "${V}󰄬 ${B}OK:${RESET} $1"; }
step()    { echo -e "\n${B}${C}  ▶  $*${RESET}\n"; }

confirm() {
    echo -en "${G}  [?] $1 [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

# ── Funzione per creare link simbolici 
safe_link() {
    local src="$1"
    local dst="$2"
    
    if [[ -e "$src" ]]; then
        # Se la cartella esiste,crea un backup
        if [[ -d "$dst" && ! -L "$dst" ]]; then
            warn "Backup cartella esistente: $dst"
            mv "$dst" "${dst}.bak_$(date +%H%M%S)"
        fi

        mkdir -p "$(dirname "$dst")"
        
        # Usa -n (o --no-dereference) evita link loop
        ln -sfn "$src" "$dst"
    else
        err "Sorgente non trovata: $src"
    fi
}

# ── Header 
header() {
    clear
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
    echo -e "${B}${V}    󰊠  ILNANNY OS-MANAGER v2.6 - [${C}${OS_ID^^}${V}]${RESET}"
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
}

# ── Installazione Dipendenze 
install_deps() {
    step "Verifica software di sistema su $OS_ID"
    declare -A PKGS
    PKGS[fedora]="curl wget gh xdg-user-dirs git tree dust inkscape python3-pip glow zsh fzf ripgrep"
    PKGS[void]="curl wget github-cli xdg-user-dirs git tree dust inkscape python3-pip glow"
    PKGS[arch]="curl wget github-cli xdg-user-dirs git tree dust inkscape python-pip glow"
    PKGS[debian]="curl wget gh xdg-user-dirs git tree inkscape du-dust python3-pip glow"
    PKGS[mx]="${PKGS[debian]}"

    local pkg_list="${PKGS[$OS_ID]}"
    [[ -z "$pkg_list" ]] && return

    local da_installare=()
    for pkg in $pkg_list; do
        local cmd="$pkg"
        [[ "$pkg" == "github-cli" ]] && cmd="gh"
        command -v "$cmd" &>/dev/null || da_installare+=("$pkg")
    done

    if [[ ${#da_installare[@]} -gt 0 ]]; then
        if confirm "Installare componenti mancanti? (${da_installare[*]})"; then
            case "$OS_ID" in
                fedora)    sudo dnf install -y "${da_installare[@]}" ;;
                void)      sudo xbps-install -Sy "${da_installare[@]}" ;;
                arch)      sudo pacman -Sy --needed --noconfirm "${da_installare[@]}" ;;
                debian|mx) sudo apt-get update && sudo apt-get install -y "${da_installare[@]}" ;;
            esac
        fi
    else
        ok "Sistema aggiornato."
    fi
}

# ── Gestione Link Simbolici 
deploy_bashrc() {
    step "Configurazione Bash"
    mkdir -p ~/.bashrc.d
    safe_link "$DOTFILES/bash/etc_bash/bashrc" ~/.bashrc
    
    info "Linkando moduli comuni..."
    for f in "$DOTFILES/bash/etc_bash/bashrc.d"/*; do
        [[ -e "$f" ]] && safe_link "$f" ~/.bashrc.d/"$(basename "$f")"
    done
    
    local distro_target=""
    case "$OS_ID" in
        fedora)    distro_target="$DOTFILES/Fedora/etc/bash/bashrc.d" ;;
        debian|mx) distro_target="$DOTFILES/Debian/etc/bash/bashrc.d" ;;
        arch)      distro_target="$DOTFILES/Arch/etc/bash/bashrc.d" ;;
        void)      distro_target="$DOTFILES/Void/etc/bash/bashrc.d" ;;
    esac

    if [[ -n "$distro_target" && -d "$distro_target" ]]; then
        info "Linkando moduli specifici per $OS_ID..."
        for f in "$distro_target"/*; do
            [[ -e "$f" ]] && safe_link "$f" ~/.bashrc.d/"$(basename "$f")"
        done
    fi
}

deploy_bin() {
    step "Script ~/bin"
    mkdir -p ~/bin
    for f in "$DOTFILES"/scripts/bin/*; do
        chmod +x "$f"
        safe_link "$f" ~/bin/"$(basename "$f")"
    done
}

deploy_config() {
    step "Deploy ~/.config"
    mkdir -p "$HOME/.config"
    for src in "$DOTFILES/config"/*; do
        [[ "$(basename "$src")" == "Code" ]] && continue
        
        target="$HOME/.config/$(basename "$src")"
        safe_link "$src" "$target"
    done
    
    if [[ "$OS_ID" == "fedora" && -d "$DOTFILES/Fedora/config" ]]; then
        for src in "$DOTFILES/Fedora/config"/*; do
            target="$HOME/.config/$(basename "$src")"
            safe_link "$src" "$target"
        done
    fi
}

deploy_fonts() {
    step "Deploy NerdFonts"
    local src="$DOTFILES/NerdFonts"
    local dst="$HOME/.local/share/fonts/NerdFonts"
    [[ ! -d "$src" ]] && { warn "Cartella NerdFonts non trovata"; return; }
    safe_link "$src" "$dst"
    command -v fc-cache &>/dev/null && fc-cache -f "$HOME/.local/share/fonts" &>/dev/null
}

deploy_wallpapers() {
    step "Deploy Wallpapers"
    local src="$DOTFILES/graphics/wallpapers"
    local dst="/usr/share/wallpapers"
    [[ ! -d "$src" ]] && { warn "Wallpapers non trovati"; return; }
    
    info "Sincronizzazione wallpapers (richiede sudo)..."
    sudo mkdir -p "$dst"
    sudo cp -ru "$src"/* "$dst/" 2>/dev/null && ok "Wallpapers aggiornati."
}

# ── Utility 
clean_cache() {
    step "Pulizia cache XFCE"
    rm -rf ~/.cache/sessions/* ~/.cache/xfce4/*
    ok "Cache pulita."
}

reload_xfce() {
    step "Ricarica Ambiente Desktop"
    # Ignora errori se i processi non sono attivi
    pkill -x xfwm4 xfsettingsd xfdesktop xfce4-panel 2>/dev/null
    sleep 1
    nohup xfsettingsd >/dev/null 2>&1 &
    nohup xfwm4 >/dev/null 2>&1 &
    nohup xfdesktop >/dev/null 2>&1 &
    nohup xfce4-panel >/dev/null 2>&1 &
    disown -a
    ok "Ambiente ricaricato."
}

_leggi_guide() {
    local doc_dir="${DOTFILES}/docs/emergency_guides"
    [[ ! -d "$doc_dir" ]] && { err "Guide non trovate"; return; }
    local files=($(cd "$doc_dir" && ls *.md *.txt 2>/dev/null))
    header
    echo -e "${C}󰋖 SELEZIONA GUIDA DA LEGGERE:${RESET}\n"
    select g in "${files[@]}"; do
        [[ -n "$g" ]] && { 
            command -v glow >/dev/null 2>&1 && glow -p "$doc_dir/$g" || less "$doc_dir/$g"
            break 
        }
    done
}

# ── Menu Master 
while true; do
    header
    echo -e "${C}╔═══════════════════════════════════════════════════╗${RESET}"
    printf "${C}║${RESET}  ${V}1)${RESET}  🚀 %-40s${C}║${RESET}\n" "SETUP TOTALE (Install + Link + Reload)"
    printf "${C}║${RESET}  ${V}2)${RESET}  ⚙️  %-40s${C}║${RESET}\n" "SOLO RE-DEPLOY CONFIG"
    printf "${C}║${RESET}  ${V}3)${RESET}  󰊢 %-41s${C}║${RESET}\n" "GIT PUSH (Manager Script)"
    printf "${C}║${RESET}  ${V}4)${RESET}  󱓞 %-41s${C}║${RESET}\n" "RESTART XFCE & CLEAN"
    printf "${C}║${RESET}  ${V}5)${RESET}  󱓞 %-41s${C}║${RESET}\n" "UPDATE FONTS"
    printf "${C}║${RESET}  %-47s${C}║${RESET}\n" ""
    printf "${C}║${RESET}  ${G}6)${RESET}  󰋖 %-41s${C}║${RESET}\n" "GUIDE DI EMERGENZA"
    printf "${C}║${RESET}  ${R}0)${RESET}  󰈆 %-41s${C}║${RESET}\n" "ESCI"
    echo -e "${C}╚═══════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -en "  ${B}${C}󰘳 Inserisci codice: ${RESET}"
    read -r scelta

    case $scelta in
        1) install_deps; deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; deploy_wallpapers; clean_cache; reload_xfce; read -rp "Fine. Premi INVIO..." ;;
        2) deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; clean_cache; reload_xfce; read -rp "Fine. Premi INVIO..." ;;
        3) "$DOTFILES/scripts/bin/ilnanny-git-manager.sh"; read -rp "Premi INVIO..." ;;
        4) clean_cache; reload_xfce; sleep 2 ;;
        5) deploy_fonts; read -rp "Fine. Premi INVIO..." ;;
        6) _leggi_guide ;;
        0) clear; exit 0 ;;
        *) warn "Scelta non valida."; sleep 1 ;;
    esac
done
