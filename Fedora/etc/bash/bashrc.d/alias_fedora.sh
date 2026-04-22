#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Collezione di scorciatoie per DNF (Fedora)
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Gestione Pacchetti (DNF) ----------------------------
alias update='sudo dnf upgrade'                          # Aggiorna tutto il magazzino Fedora
alias instally='sudo dnf install -y'                     # Installa a colpo sicuro 
alias remove='sudo dnf remove && sudo dnf autoremove'    # Rimuovi pacchetti e dipendenze inutili
alias search='dnf search'                                # Cerca tra migliaia di pacchetti 
alias info='dnf info'                                    # Info sul pacchetto 

# NUOVO: Pulizia sistema Cache, Temp e Cestino
alias clean='sudo dnf clean all && rm -rf /tmp/* && rm -rf ~/.local/share/Trash/*'

# --- 📂 Navigazione Lab ----------------------------------
alias dots='cd ~/dotfiles'                              # Cartella principale dei dotfiles 
alias gbin='cd ~/dotfiles/scripts/bin'                  # Entra nel cuore degli script
alias cdd='cd ~/dotfiles/bash/etc_bash/bashrc.d/'       # Vai dove nascono gli alias 
alias docs='cd ~/dotfiles/docs_lab'                     # Leggi i manuali del Lab 

# --- 📔 Utility e Visualizzazione ------------------------
alias vedi='ls -sh --color=auto -I "*.png" -I "*.jpg" -I "*.pdf"' # Guarda i file senza il "rumore" dei binari 
alias treed='tree -h --du -a -C -I "*.png|*.jpg|*.pdf"'  # Albero delle cartelle pulito e veloce
