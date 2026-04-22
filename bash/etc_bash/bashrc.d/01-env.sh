#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════════════════
# Nota:Definisce le variabili d'ambiente globali,
# personalizzazione della cronologia e delle pagine MAN.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════════════════════════════

# ---  Colori ANSI (Variabili testo) -------------------------------------------------------
red='\[\e[0;31m\]'                           # Rosso: Errori o avvisi
blue='\[\e[0;34m\]'                          # Blu: Directory o Host
cyan='\[\e[0;36m\]'                          # Ciano: Info secondarie
green='\[\e[0;32m\]'                         # Verde: Successo o Utente
nc='\[\e[0m\]'                               # Reset: Torna al predefinito

# --- ⚙ Variabili di Sistema ----------------------------------------------------------------
export LANG="it_IT.UTF-8"                    # Imposta la lingua di sistema
export LC_ALL="it_IT.UTF-8"                  # Forza la localizzazione globale
export XKBMAP="it"                           # Definisce il layout della tastiera
export TERM="xterm-256color"                 # Abilita il supporto ai 256 colori
export EDITOR="geany"                        # Imposta l'editor di testo predefinito
export BROWSER="firefox"                     # Imposta il browser predefinito
export FILEMANAGER="thunar"                  # Definisce il gestore file predefinito
export QT_QPA_PLATFORMTHEME=qt5ct            # Gestisce il tema Qt tramite qt5ct

# ---  Integrazione Gemini Protetta --------------------------------------------------------
if [ -f "$HOME/.gemini_key" ]; then
    . "$HOME/.gemini_key"                    # Carica la chiave API se presente
fi

# ---  Gestione Percorsi (PATH) ------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"       # Definisce il percorso config standard
export NPM_CONFIG_PREFIX="$HOME/.npm-global" # Supporto NPM locale, evita errori EACCES
export PATH="$HOME/.npm-global/bin:$HOME/dotfiles/scripts/bin:$HOME/bin:$PATH"
               # NPM globale -> Script Dotfiles -> Script personali bin -> Path di sistema
# ---  Cronologia (History) ----------------------------------------------------------------
export HISTSIZE=10000                        # Numero di comandi mantenuti in RAM
export HISTFILESIZE=20000                    # Righe totali salvate su file disco
export HISTCONTROL=ignoreboth:erasedups      # Ignora duplicati e comandi con spazio
export HISTIGNORE="ls:cd:exit:q:f:v"         # Elenca i comandi da non memorizzare

# ---  Colori Pagine MAN (Less) ------------------------------------------------------------
export LESS_TERMCAP_mb=$'\E[01;31m'          # Inizio lampeggiante (Rosso)
export LESS_TERMCAP_md=$'\E[01;31m'          # Inizio grassetto (Rosso)
export LESS_TERMCAP_me=$'\E[0m'              # Fine di tutte le formattazioni
export LESS_TERMCAP_se=$'\E[0m'              # Fine della modalità evidenziata
export LESS_TERMCAP_so=$'\E[01;44;33m'       # Modalità ricerca (Sfondo Blu/Giallo)
export LESS_TERMCAP_ue=$'\E[0m'              # Fine della sottolineatura
export LESS_TERMCAP_us=$'\E[01;32m'          # Inizio sottolineatura (Verde)

export GPG_TTY=$(tty)                        # Collega il terminale corrente a GPG

# -----------------------------------  F i n e  ---------------------------------------------
