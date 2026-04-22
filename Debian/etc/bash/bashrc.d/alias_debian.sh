#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Collezione di scorciatoie per APT
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Gestione Pacchetti (APT) ----------------------------
alias update='sudo apt update && sudo apt upgrade'       # Aggiorna tutto il magazzino Debian 
alias instally='sudo apt install -y'                     # Installa a colpo sicuro 
alias purge='sudo apt purge && sudo apt autoremove'      # Pulizia totale e profonda 
alias search='apt search'                                # Cerca tra migliaia di pacchetti 
alias show='apt show'                                    # Info sul pacchetto 

# NUOVO: Pulizia sistema Cache, Temp e Cestino
alias clean='sudo apt clean && sudo apt autoremove -y && rm -rf /tmp/* && rm -rf ~/.local/share/Trash/*'

# --- 📂 Navigazione Lab ( ----------
alias dots='cd ~/dotfiles'                              # Cartella principale dei dotfiles 
alias gbin='cd ~/dotfiles/scripts/bin'                  # Entra nel cuore degli script
alias cdd='cd ~/dotfiles/bash/etc_bash/bashrc.d/'       # Vai dove nascono gli alias 
alias docs='cd ~/dotfiles/docs_lab'                     # Leggi i manuali del Lab 

# --- 🚀 Master Commands  ----------
# Il manager universale per caricare tutto su GitHub
alias pigia='~/dotfiles/scripts/bin/ilnanny-git-manager.sh' # Sincronizza il dotfile con github 
alias manager='~/dotfiles/ilnanny-OS-manager.sh' # 

# --- 📔 Utility e Visualizzazione ------------------------
alias vedi='ls -sh --color=auto -I "*.png" -I "*.jpg" -I "*.pdf"' # Guarda i file senza il "rumore" dei binari 
alias treed='tree -h --du -a -C -I "*.png|*.jpg|*.pdf"'  # Albero delle cartelle pulito e veloce
