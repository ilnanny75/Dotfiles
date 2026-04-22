#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Arch Lab Alias Manager. Scorciatoie ottimizzate per pacman, 
# gestione mirror con reflector, pulizia orfani e comandi rapidi 
# per la manutenzione del sistema Arch Linux.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Gestione Pacchetti (Pacman) -------------------------
alias pacman='sudo pacman --color auto'      # Colora l'output per non diventare matti
alias update='sudo pacman -Syyu'             # Il rinfresco totale del sistema
alias install='sudo pacman -S'               # Porta a casa un nuovo pacchetto
alias remove='sudo pacman -Rs'               # Rimuove il pacchetto e le sue dipendenze inutili
alias search='pacman -Ss'                    # Cerca nel magazzino di Arch
alias pacchetti='pacman -Ql'                 # Fammi vedere cosa ha installato questo pacchetto
alias scc='sudo pacman -Scc'                 # Pulizia drastica della cache (usa con testa!)
alias qdt='pacman -Qdt'                      # Elenca i pacchetti orfani
alias qdtr='sudo pacman -Rs $(pacman -Qdtq)' # Rimuovili tutti i pacchetti orfani

# --- Manutenzione e Sicurezza ----------------------------
# Trova i 10 mirror più veloci e aggiorna la lista
alias mirror='sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
# Chi è arrivato per ultimo? Mostra gli ultimi 100 pacchetti installati
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -100"
# Caccia via gli orfani (pacchetti rimasti soli e inutilizzati)
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
# Se Pacman si incastra, questo toglie il lucchetto
alias unlock='sudo rm /var/lib/pacman/db.lck'

# --- Gestione AUR (Yay) ----------------------------------
alias ynstall='yay -S'                       # Installa le chicche da AUR
alias ysearch='yay -Ss'                      # Cerca nel mondo AUR
alias yremove='yay -Rs'                      # Rimuove pacchetti AUR
