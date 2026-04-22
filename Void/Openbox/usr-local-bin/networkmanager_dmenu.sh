#!/bin/bash
#================================================
#   O.S.      : Gnu Linux
#   Author    : Cristian Pozzessere   = ilnanny
#   Github    : https://github.com/ilnanny75
#================================================

# Logica di avvio senza percorsi fissi
if command -v networkmanager_dmenu >/dev/null 2>&1; then
    networkmanager_dmenu "$@"
else
    echo "Errore: networkmanager_dmenu non installato."
    echo -e "\nPremi INVIO per uscire..."
    read -r
fi
