#!/bin/bash
# ═══════════════════════════════════════════
# Nota: Backup e ripristino di Code - VsCode
#  Autore: ilnanny 2026
# ═══════════════════════════════════════════

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

SOURCE_DIR="$HOME/.config/Code/User"
DOTFILES_DIR="$HOME/dotfiles/config/Code"
DOT_SNIPPETS="$DOTFILES_DIR/snippets" 
EXT_LIST="$DOTFILES_DIR/extensions.txt"

# Assicurati che la cartella dei dotfiles esista
mkdir -p "$DOT_SNIPPETS"

backup_vscode() {
    echo -e "${BLUE}Avvio backup VS Code...${RESET}"

    if ! command -v code &> /dev/null; then
        echo -e "${RED}Errore: comando 'code' non trovato (VS Code è installato?)${RESET}"
        return
    fi

    # Backup file principali
    [ -f "$SOURCE_DIR/settings.json" ] && cp "$SOURCE_DIR/settings.json" "$DOTFILES_DIR/"
    [ -f "$SOURCE_DIR/keybindings.json" ] && cp "$SOURCE_DIR/keybindings.json" "$DOTFILES_DIR/"
    
    # Backup Snippets
    if [ -d "$SOURCE_DIR/snippets" ]; then
        cp -r "$SOURCE_DIR/snippets/." "$DOT_SNIPPETS/"
        echo -e "${GREEN}Snippets copiati.${RESET}"
    fi

    # Lista estensioni
    code --list-extensions > "$EXT_LIST"
    echo -e "${GREEN}Backup completato con successo!${RESET}"
}

restore_vscode() {
    echo -e "${BLUE}Ripristino configurazione VS Code...${RESET}"
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${RED}Errore: Cartella backup non trovata in $DOTFILES_DIR${RESET}"
        return
    fi

    TIMESTAMP=$(date +%Y%m%d-%H%M%S)

    # Backup di sicurezza della config attuale
    echo -e "Creazione backup di sicurezza in $SOURCE_DIR..."
    for file in "settings.json" "keybindings.json"; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            mv "$SOURCE_DIR/$file" "$SOURCE_DIR/$file.$TIMESTAMP.bak"
        fi
    done

    if [ -d "$SOURCE_DIR/snippets" ]; then
         mv "$SOURCE_DIR/snippets" "$SOURCE_DIR/snippets.$TIMESTAMP.bak"
    fi
    mkdir -p "$SOURCE_DIR/snippets"

    # Ripristino dai dotfiles
    cp "$DOTFILES_DIR/settings.json" "$SOURCE_DIR/" 2>/dev/null
    cp "$DOTFILES_DIR/keybindings.json" "$SOURCE_DIR/" 2>/dev/null
    cp -r "$DOT_SNIPPETS/." "$SOURCE_DIR/snippets/" 2>/dev/null

    # Installazione estensioni
    if [ -f "$EXT_LIST" ]; then
        echo -e "${BLUE}Installazione estensioni in corso (potrebbe richiedere tempo)...${RESET}"
        while read -r ext; do
            code --install-extension "$ext" --force
        done < "$EXT_LIST"
    fi

    echo -e "${GREEN}Ripristino completato!${RESET}"
}

# Menu Semplice
echo -e "${BLUE}--- VS CODE SYNC TOOL ---${RESET}"
echo "1) Backup (da PC a Dotfiles)"
echo "2) Restore (da Dotfiles a PC)"
echo "3) Esci"
read -p "Scegli un'opzione: " opzione

case $opzione in
    1) backup_vscode ;;
    2) restore_vscode ;;
    3) exit 0 ;;
    *) echo -e "${RED}Opzione non valida${RESET}" ;;
esac
