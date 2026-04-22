#!/bin/bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere   = ilnanny
#   Github    : https://github.com/ilnanny75
#================================================

# Ottiene l'ora e la data attuale
ORARIO=$(date "+%H:%M:%S")
DATA=$(date "+%A, %d %B %Y")

# Invia una notifica a video (Dunst)
if command -v dunstify >/dev/null 2>&1; then
    dunstify -u low -i clock "Orario di Sistema" "$ORARIO\n$DATA"
else
    notify-send "Orario di Sistema" "$ORARIO - $DATA"
fi

# Mostra anche nel terminale se avviato a mano
echo -e "L'ora attuale è: \e[1;32m$ORARIO\e[0m"
echo -e "Data: $DATA"

# Non mettio "Premi INVIO" qui perché spesso lo si usa con una scorciatoia rapida.
exit 0
