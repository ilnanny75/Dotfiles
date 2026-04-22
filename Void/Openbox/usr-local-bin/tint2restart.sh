#!/usr/bin/env bash
#================================================
#   O.S.   : Void Linux
#   Author : Cristian Pozzessere = ilnanny75
#   Github : https://github.com/ilnanny75
#================================================

if ! pidof tint2 >/dev/null; then
    echo "Nessuna istanza di tint2 trovata."
    exit 0
fi

# Trova i comandi esatti usati per avviare i tint2 e li riavvia
mapfile -t COMMANDS < <(pgrep -a tint2 | awk '{$1=""; print $0}')

killall tint2
sleep 1

for cmd in "${COMMANDS[@]}"; do
    (setsid $cmd &)
done

exit 0
