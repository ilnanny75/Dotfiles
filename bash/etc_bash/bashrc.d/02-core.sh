#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Unifica alias, gestione Git, utility di estrazione
# e manipolazione multimediale.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# ---  Navigazione e Struttura -----------------------
alias blkid='lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL'
alias ls='ls --group-directories-first --color=auto'
alias l='ls -la'
alias ll='ls -lh'
alias vedi='ls -sh --color=auto --group-directories-first -I "*.png" -I "*.jpg" -I "*.pdf" -I "*.webp" -I "*.svg" -I "*.xbm" -I ".git"'
alias treed='tree -h --du -a -C --dirsfirst -I ".git|*.webp|*.xbm|*.png|*.jpg|*.pdf|*.svg"'
alias ds='dust'

# ---  Percorsi Rapidi -------------------------------
alias dots='cd ~/dotfiles'
alias gbin='cd ~/dotfiles/scripts/bin'
alias cdd='cd ~/dotfiles/bash/etc_bash/bashrc.d/'
alias godot='thunar ~/dotfiles &'

# ---  Utility di Sistema e AI -----------------------
alias gemini='python3 gemini.py'
alias software='ilnanny-postinstall.sh'
alias meteo='curl wttr.in/Taranto'
alias install-grub-sda='sudo grub-install /dev/sda'

# Grub globale
update_grub_custom() {
    if [ -f /boot/efi/EFI/fedora/grub.cfg ]; then
        sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    elif [ -f /boot/grub2/grub.cfg ]; then
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
}
alias update-grub-all='update_grub_custom'

ii() { # Visualizza riepilogo rapido del sistema
    echo -e "\nSei su: \e[1;31m$HOSTNAME\e[m"
    echo -e "\n\e[1;31mKernel:\e[m "; uname -a
    echo -e "\n\e[1;31mMemoria:\e[m"; free -h
    echo -e "\n\e[1;31mIP Loc.:\e[m "; hostname -I
}

# ---  Gestione Archivi ------------------------------
extract() { # Estrattore universale per vari formati
    arg="$1"; shift
    case $arg in
        -e|--extract)
            if [[ $1 && -e $1 ]]; then
                case $1 in
                    *.tar.bz2|*.tbz2) tar xvjf "$1" ;;
                    *.tar.gz|*.tgz)   tar xvzf "$1" ;;
                    *.zip)            unzip "$1"    ;;
                    *.7z|*.7zip)      7za e "$1"    ;;
                    *.rar)            unrar x "$1"  ;;
                    *) echo "'$1' non supportato"   ;;
                esac
            fi ;;
    esac
}

# ---  Git & GitHub ----------------------------------
alias gsync='git pull --no-rebase && git add -A && git commit -m "Sync locale-remoto $(date +%d-%m-%Y_%H:%M)" && git push'
alias pigia='ilnanny-git-manager.sh'
alias multigit='git-multitool.sh'
gclone_cd() { # Clona ed entra automaticamente nella directory
    git clone "$1" && cd "$(basename "$1" .git)"
}
alias gc='gclone_cd'

# ---  Grafica e Ottimizzazione ----------------------
alias wallopt='wallpaper-optimize.sh'
alias svgopt='ilnanny-optimize.sh'
svg2png() { # Converte SVG in PNG specificando la dimensione
    convert -background none -size "$2"x"$2" "$1" "${1%.*}-$2.png"
}
