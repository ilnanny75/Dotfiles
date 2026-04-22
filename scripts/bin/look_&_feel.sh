#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# Nota: Desktop Look & Feel Installer (XFCE4)
# Autore: ilnanny 2026
# Contenuto: Nordic GTK (Selective) + Lila-HD Icons & Cursor
# ═══════════════════════════════════════════════════════════════════

# --- Colori Nord ---
N8="#88C0D0"  # Frost
N10="#5E81AC" # Arctic Ocean
N13="#EBCB8B" # Aurora Yellow
N14="#A3BE8C" # Aurora Green
NC="\033[0m"

# --- Configurazione Percorsi ---
THEME_DIR="$HOME/.themes/Nordic"
ICONS_DIR="$HOME/.icons/Lila-HD"
NORD_REPO="https://github.com/EliverLara/Nordic.git"
LILA_REPO="https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official.git"

echo -e "${N10}>>> Avvio setup estetico XFCE (Senza sbatti edition) <<<${NC}"

# 1. INSTALLAZIONE TEMA NORDIC (Solo l'essenziale)
if [ ! -d "$THEME_DIR" ]; then
    echo -e "${N8}[*] Scaricamento mirato Nordic GTK...${NC}"
    mkdir -p "$THEME_DIR"
    cd "$THEME_DIR" || exit
    git init > /dev/null
    git remote add -f origin "$NORD_REPO" > /dev/null
    git config core.sparseCheckout true
    
    # Selezioniamo solo XFCE e GTK
    echo "gtk-2.0/" >> .git/info/sparse-checkout
    echo "gtk-3.0/" >> .git/info/sparse-checkout
    echo "gtk-4.0/" >> .git/info/sparse-checkout
    echo "xfwm4/" >> .git/info/sparse-checkout
    echo "index.theme" >> .git/info/sparse-checkout
    
    git pull origin master > /dev/null 2>&1
    rm -rf .git
    echo -e "${N14}[V] Tema Nordic pronto.${NC}"
else
    echo -e "${N14}[V] Tema Nordic già presente.${NC}"
fi

# 2. INSTALLAZIONE ICONE E CURSORE LILA-HD
if [ ! -d "$ICONS_DIR" ]; then
    echo -e "${N8}[*] Scaricamento icone e cursore Lila-HD...${NC}"
    mkdir -p "$HOME/.icons"
    git clone --depth 1 "$LILA_REPO" "$ICONS_DIR" > /dev/null 2>&1
    rm -rf "$ICONS_DIR/.git"
    echo -e "${N14}[V] Icone e Cursore installati.${NC}"
else
    echo -e "${N14}[V] Lila-HD già presente.${NC}"
fi

# 3. APPLICAZIONE IMPOSTAZIONI XFCE
echo -e "${N13}[!] Configurazione ambiente desktop...${NC}"

# Tema Aspetto
xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic"

# Icone
xfconf-query -c xsettings -p /Net/IconThemeName -s "Lila-HD"

# --- FIX CURSORE ---
# Imposta il puntatore su XFCE
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Lila-HD"

# Fix per applicazioni legacy/root (crea il file default)
mkdir -p "$HOME/.icons/default"
echo -e "[Icon Theme]\nInherits=Lila-HD" > "$HOME/.icons/default/index.theme"

# Window Manager (Bordi finestre)
xfconf-query -c xfwm4 -p /general/theme -s "Nordic"

echo -e "${N14}>>> Fatto! Ora puoi tornare a non far nulla. <<<${NC}"
