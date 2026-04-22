#!/usr/bin/env bash
# ============================================================
#  grub-deploy.sh — Deploy configurazione GRUB per Fedora
#  Autore : ilnanny
#  Versione: 1.0
#  Descrizione: Installa font, sfondo e configurazione GRUB
#               da ~/dotfiles/Fedora/grub-config/
# ============================================================

set -euo pipefail

# --- COLORI ---
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
B='\033[1;34m'; C='\033[1;36m'; W='\033[1;37m'; N='\033[0m'

# --- PERCORSI ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
GRUB_CONFIG_SRC="$DOTFILES_DIR/grub"
WALLPAPER_SRC="$DOTFILES_DIR/xfce-pantone-grub.png"
WALLPAPER_DST="/usr/share/wallpapers/xfce-pantone.png"
FONT_DIR="/boot/grub2/fonts"
FONT_NAME="DejaVuSansMono32.pf2"
FONT_SRC_TTF="/usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf"
FONT_DST="$FONT_DIR/$FONT_NAME"
GRUB_DST="/etc/default/grub"
GRUB_CFG="/boot/grub2/grub.cfg"

# --- FUNZIONI UI ---
banner() {
    clear
    echo -e "${B}╔══════════════════════════════════════════════════╗${N}"
    echo -e "${B}║${C}   ██████  ██████  ██   ██ ██████                ${B}║${N}"
    echo -e "${B}║${C}  ██       ██   ██ ██   ██ ██   ██               ${B}║${N}"
    echo -e "${B}║${C}  ██   ███ ██████  ██   ██ ██████                ${B}║${N}"
    echo -e "${B}║${C}  ██    ██ ██   ██ ██   ██ ██   ██               ${B}║${N}"
    echo -e "${B}║${C}   ██████  ██   ██  █████  ██████                ${B}║${N}"
    echo -e "${B}║                                                  ║${N}"
    echo -e "${B}║${W}        Deploy Configurazione GRUB               ${B}║${N}"
    echo -e "${B}║${Y}        Fedora — ilnanny dotfiles                ${B}║${N}"
    echo -e "${B}╚══════════════════════════════════════════════════╝${N}"
    echo
}

info()    { echo -e "${C}  ➤  ${W}$*${N}"; }
ok()      { echo -e "${G}  ✔  $*${N}"; }
warn()    { echo -e "${Y}  ⚠  $*${N}"; }
errore()  { echo -e "${R}  ✘  $*${N}"; }
titolo()  { echo -e "\n${B}━━━  ${Y}$*${B}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"; }

conferma() {
    echo -e "${Y}  ?  $1 [s/N]: ${N}\c"
    read -r risp
    [[ "${risp,,}" == "s" ]]
}

# --- CONTROLLO ROOT ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        errore "Questo script richiede i privilegi di root."
        echo -e "    Rilancialo con: ${W}sudo $0${N}"
        exit 1
    fi
}

# --- CONTROLLO FILE SORGENTE ---
check_sorgenti() {
    titolo "Verifica file sorgente"
    local ok=true

    if [[ -f "$GRUB_CONFIG_SRC" ]]; then
        ok "File config GRUB trovato: $GRUB_CONFIG_SRC"
    else
        errore "File config GRUB NON trovato: $GRUB_CONFIG_SRC"
        ok=false
    fi

    if [[ -f "$WALLPAPER_SRC" ]]; then
        ok "Wallpaper trovato: $WALLPAPER_SRC"
    else
        errore "Wallpaper NON trovato: $WALLPAPER_SRC"
        ok=false
    fi

    if [[ "$ok" == false ]]; then
        echo
        errore "File mancanti. Assicurati di eseguire lo script da ~/dotfiles/Fedora/grub-config/"
        exit 1
    fi
}

# --- STEP 1: BACKUP ---
backup_grub() {
    titolo "Backup configurazione attuale"
    local backup_dir="/etc/default/grub.bak.$(date +%Y%m%d_%H%M%S)"
    if [[ -f "$GRUB_DST" ]]; then
        cp "$GRUB_DST" "${backup_dir}"
        ok "Backup salvato in: ${backup_dir}"
    else
        warn "Nessun file GRUB esistente da backuppare."
    fi
}

# --- STEP 2: INSTALL FONT ---
installa_font() {
    titolo "Installazione font GRUB"

    if [[ -f "$FONT_DST" ]]; then
        ok "Font già presente: $FONT_DST"
        return 0
    fi

    # Verifica che il TTF sorgente esista
    if [[ ! -f "$FONT_SRC_TTF" ]]; then
        warn "Font TTF non trovato in $FONT_SRC_TTF"
        info "Installo il pacchetto dejavu-sans-mono-fonts..."
        dnf install -y dejavu-sans-mono-fonts &>/dev/null
    fi

    mkdir -p "$FONT_DIR"
    info "Generazione font PF2 (32pt)..."
    grub2-mkfont -s 32 -o "$FONT_DST" "$FONT_SRC_TTF"
    ok "Font generato: $FONT_DST"
}

# --- STEP 3: INSTALL WALLPAPER ---
installa_wallpaper() {
    titolo "Installazione wallpaper GRUB"
    mkdir -p /usr/share/wallpapers
    cp "$WALLPAPER_SRC" "$WALLPAPER_DST"
    chmod 644 "$WALLPAPER_DST"
    ok "Wallpaper installato: $WALLPAPER_DST"

    # Verifica tipo PNG (deve essere RGB, non RGBA)
    local tipo
    tipo=$(python3 -c "
from PIL import Image
img = Image.open('$WALLPAPER_DST')
print(img.mode)
" 2>/dev/null || echo "?")

    if [[ "$tipo" == "RGB" ]]; then
        ok "Formato PNG corretto: RGB 24-bit ✓"
    elif [[ "$tipo" == "RGBA" ]]; then
        warn "Immagine RGBA rilevata — GRUB non supporta la trasparenza!"
        warn "Conversione automatica a RGB..."
        python3 -c "
from PIL import Image
img = Image.open('$WALLPAPER_DST')
rgb = Image.new('RGB', img.size, (0,0,0))
rgb.paste(img, mask=img.split()[3])
rgb.save('$WALLPAPER_DST', 'PNG')
print('Conversione completata.')
"
        ok "Convertito in RGB 24-bit ✓"
    else
        warn "Impossibile verificare il formato PNG (python3-pillow installato?)"
    fi
}

# --- STEP 4: INSTALLA CONFIG ---
installa_config() {
    titolo "Installazione /etc/default/grub"
    cp "$GRUB_CONFIG_SRC" "$GRUB_DST"
    chmod 644 "$GRUB_DST"
    ok "Configurazione GRUB installata."
    info "Anteprima parametri chiave:"
    grep -E "^GRUB_(TIMEOUT|FONT|BACKGROUND|GFXMODE|CMDLINE)" "$GRUB_DST" \
        | sed "s/^/    ${Y}/; s/$/${N}/"
}

# --- STEP 5: RIGENERA GRUB.CFG ---
rigenera_grub() {
    titolo "Rigenerazione grub.cfg"
    info "Esecuzione grub2-mkconfig..."
    grub2-mkconfig -o "$GRUB_CFG" 2>&1 | grep -v "^$" | sed "s/^/    /"
    echo

    # Verifica risultato
    if grep -q "background_image" "$GRUB_CFG" 2>/dev/null; then
        ok "background_image trovato in grub.cfg ✓"
    else
        warn "background_image NON trovato in grub.cfg — controlla il percorso del wallpaper."
    fi

    if grep -q "loadfont" "$GRUB_CFG" 2>/dev/null; then
        ok "Font caricato in grub.cfg ✓"
    else
        warn "loadfont NON trovato in grub.cfg — controlla il percorso del font."
    fi
}

# --- RIEPILOGO FINALE ---
riepilogo() {
    echo
    echo -e "${B}╔══════════════════════════════════════════════════╗${N}"
    echo -e "${B}║${G}            DEPLOY COMPLETATO ✔                  ${B}║${N}"
    echo -e "${B}╠══════════════════════════════════════════════════╣${N}"
    echo -e "${B}║${N}  Font    : ${W}$FONT_DST${N}"
    echo -e "${B}║${N}  Sfondo  : ${W}$WALLPAPER_DST${N}"
    echo -e "${B}║${N}  Config  : ${W}$GRUB_DST${N}"
    echo -e "${B}║${N}  GRUB cfg: ${W}$GRUB_CFG${N}"
    echo -e "${B}╠══════════════════════════════════════════════════╣${N}"
    echo -e "${B}║${Y}  Riavvia per vedere le modifiche al GRUB        ${B}║${N}"
    echo -e "${B}╚══════════════════════════════════════════════════╝${N}"
    echo
}

# ============================================================
# MAIN
# ============================================================
banner
check_root
check_sorgenti

echo -e "${W}  Questo script installerà:${N}"
echo -e "  ${C}•${N} Font DejaVuSansMono 32pt in $FONT_DIR"
echo -e "  ${C}•${N} Wallpaper GRUB in $WALLPAPER_DST"
echo -e "  ${C}•${N} Config GRUB in $GRUB_DST"
echo -e "  ${C}•${N} Rigenerazione di $GRUB_CFG"
echo

if ! conferma "Procedere con il deploy?"; then
    warn "Operazione annullata."
    exit 0
fi

backup_grub
installa_font
installa_wallpaper
installa_config
rigenera_grub
riepilogo
