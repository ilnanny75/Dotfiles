#!/usr/bin/env bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================

# Configurazione veloce
TERMINAL="st" # o il tuo terminale preferito
FILE_MANAGER="pcmanfm" # o thunar

# Se viene passato un percorso, usa quello, altrimenti usa la Home
if [ -d "$1" ]; then
    DIR="$1"
else
    DIR="$HOME"
fi

echo "<openbox_pipe_menu>"

# Voce per aprire la cartella nel File Manager
echo "  <item label=\"Apri qui ($FILE_MANAGER)\">"
echo "    <action name=\"Execute\"><command>$FILE_MANAGER \"$DIR\"</command></action>"
echo "  </item>"
echo "  <separator />"

# Ciclo per mostrare cartelle e file
for i in "$DIR"/*; do
    [ -e "$i" ] || continue
    NAME=$(basename "$i")

    if [ -d "$i" ]; then
        # Se è una directory, crea un sottomenu ricorsivo
        echo "  <menu id=\"$i\" label=\"$NAME/\" execute=\"$0 '$i'\" />"
    else
        # Se è un file, prova ad aprirlo con xdg-open
        echo "  <item label=\"$NAME\">"
        echo "    <action name=\"Execute\"><command>xdg-open \"$i\"</command></action>"
        echo "  </item>"
    fi
done

echo "</openbox_pipe_menu>"
