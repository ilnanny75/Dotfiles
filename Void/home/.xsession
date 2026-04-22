#!/bin/bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================
#   Descrizione: Script di avvio per Login Grafici
#================================================

# Questo file viene letto dai Display Manager (es. LightDM).
# Carica l'ambiente dell'utente come se fossi in una shell di login.
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Se esiste un file .xinitrc, usalo per avviare la sessione.
# Questo ti permette di mantenere tutta la logica di scelta
# del desktop in un unico posto (.xinitrc).
if [ -f ~/.xinitrc ]; then
    exec /bin/bash --login ~/.xinitrc
else
    # Fallback: se .xinitrc non esiste, prova ad avviare
    # Openbox o XFCE come ultima spiaggia.
    if command -v openbox-session >/dev/null 2>&1; then
        exec openbox-session
    else
        exec startxfce4
    fi
fi
