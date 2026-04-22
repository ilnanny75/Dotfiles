#!/usr/bin/env bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================

# Percorso del file cache
EMOJI_FILE="$HOME/.cache/emojis.txt"

# Se il file non esiste, scaricalo o crealo (versione base)
if [ ! -f "$EMOJI_FILE" ]; then
    echo "😂 Faccina" > "$EMOJI_FILE"
    echo "❤️ Cuore" >> "$EMOJI_FILE"
    echo "👍 Ottimo" >> "$EMOJI_FILE"
    echo "🚀 VoidLinux" >> "$EMOJI_FILE"
fi

# Visualizza con rofi
CHOICE=$(cat "$EMOJI_FILE" | rofi -dmenu -i -p "Emoji:" -theme-str 'window {width: 400;}')

if [ -n "$CHOICE" ]; then
    # Estrae solo l'emoji (il primo carattere/simbolo)
    EMOJI=$(echo "$CHOICE" | awk '{print $1}')

    # Copia negli appunti (richiede xsel o xclip)
    echo -n "$EMOJI" | xclip -selection clipboard

    # Scrive l'emoji direttamente (richiede xdotool)
    sleep 0.2
    xdotool type "$EMOJI"

    notify-send "Emoji Copiata" "L'emoji $EMOJI è stata inserita e copiata negli appunti."
fi
