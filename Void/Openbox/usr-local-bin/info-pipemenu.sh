#!/bin/bash
#================================================
#   O.S.      : Gnu Linux
#   Author    : Cristian Pozzessere   = ilnanny
#   Github    : https://github.com/ilnanny75
#================================================

# Esempio per info-pipemenu
echo "<openbox_pipe_menu>"
echo "  <item label=\"Kernel: $(uname -r)\" />"
echo "  <item label=\"Uptime: $(uptime -p | sed 's/up //')\" />"
echo "</openbox_pipe_menu>"
