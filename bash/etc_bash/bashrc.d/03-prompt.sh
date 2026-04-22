#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Custom Shell Prompt 2026. 
# Visualizza dinamicamente: stato ultimo comando (✔/✘), 
# info utente/host e statistiche cartella.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

prompt_dir_info() { # Conta file e calcola peso cartella attuale
    local f=$(ls -1 2>/dev/null | wc -l)
    local s=$(ls -shd . 2>/dev/null | awk '{print $1}')
    echo "$f files, $s"
}

prompt_status() { # Mostra check verde o croce rossa in base all'exit code
    if [ $? -eq 0 ]; then echo -e "\e[32m✔\e[0m"; else echo -e "\e[31m✘\e[0m"; fi
}

R="\[\e[01;31m\]"
B="\[\e[01;34m\]"
W="\[\e[01;37m\]"
RS="\[\e[0m\]"

export PS1="┌─[\$(prompt_status)]───[$W\u@\h$RS]───[$B\w$RS]───[$W\$(prompt_dir_info)$RS]\n└───▶ "
