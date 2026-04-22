#!/usr/bin/env bash
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================

TINT2RC="$HOME/.config/tint2/tint2rc"

echo "<openbox_pipe_menu>"
echo "  <item label=\"Riavvia tint2\"><action name=\"Execute\"><command>tint2restart</command></action></item>"
echo "  <separator label=\"Configurazioni\" />"
echo "  <item label=\"Modifica Default\"><action name=\"Execute\"><command>${EDITOR:-nano} $TINT2RC</command></action></item>"
echo "</openbox_pipe_menu>"
