#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Collezione di scorciatoie per DNF (Fedora)
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Gestione Pacchetti 
alias update='sudo dnf upgrade'                          # Aggiorna Fedora
alias instally='sudo dnf install -y'                     # Installa a colpo sicuro 
alias remove='sudo dnf remove && sudo dnf autoremove'    # Rimuovi pacchetti e dipendenze inutili
alias search='dnf search'                                # Cerca tra i pacchetti 
alias info='dnf info'                                    # Info sul pacchetto 

# Pulizia sistema Cache, Temp e Cestino
alias clean='sudo dnf clean all && rm -rf /tmp/* && rm -rf ~/.local/share/Trash/*'

