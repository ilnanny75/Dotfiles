#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Debian Chroot Environment Setup. Configura l'ambiente di 
# shell all'interno del chroot, gestisce il prompt colorato e 
# imposta correttamente il titolo della finestra del terminale.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# Impedisce l'esecuzione se la shell non è interattiva
case $- in
    *i*) ;;
      *) return;;
esac

# Rileva se ci si trova in un ambiente chroot
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Abilita i colori del prompt se supportati dal terminale
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Pulizia variabili temporanee
unset color_prompt force_color_prompt

# Imposta il titolo della finestra per terminali grafici
case "$TERM" in
xterm*|rxvt*|xfce4-terminal*)
    # Mostra utente, host e cartella nel titolo della finestra
    TITLEBAR="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]"
    ;;
esac
