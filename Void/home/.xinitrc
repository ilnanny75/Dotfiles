#!/bin/bash
#================================================
#   O.S.      : Void Linux (Rolling)
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================

# 1. Carica configurazioni grafiche e tastiera
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
setxkbmap it &

# 2. Pulizia file swap (opzionale ma consigliata)
find ~/.local/share/nvim/swap/ -type f -name "*.swp" -delete 2>/dev/null

# 3. Script di sistema necessari
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# --- SELETTORE AMBIENTE DESKTOP ---
# Se passi un argomento a startx (es: startx openbox), usa quello.
# Altrimenti, ti chiede cosa avviare.

SESSION=${1:-prompt}

case $SESSION in
    openbox)
        # Avvia i tuoi script prima di Openbox
        ~/Scripts/schermo2 &
        exec openbox-session
        ;;
    xfce4|xfce)
        exec startxfce4
        ;;
    prompt)
        # Se scrivi solo 'startx', ti chiede qui nel terminale
        echo "---------------------------------------"
        echo " QUALE DESKTOP VUOI AVVIARE?"
        echo " 1) Openbox (con i tuoi script)"
        echo " 2) XFCE4"
        echo " 3) Esci"
        echo "---------------------------------------"
        read -r -p "Scelta: " scelta
        case $scelta in
            1) exec ~/Scripts/schermo2 & openbox-session ;;
            2) exec startxfce4 ;;
            *) exit 0 ;;
        esac
        ;;
    *)
        # Se scrivi startx seguito da un comando che non conosco
        exec $SESSION
        ;;
esac
