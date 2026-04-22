# GUIDA CONFIGURAZIONE XDG & ICONE THUNAR

1. MODIFICA PERCORSI (user-dirs.dirs)
File: ~/.config/user-dirs.dirs
Aggiungi in fondo:
XDG_BIN_DIR="$HOME/bin"
XDG_DOTFILES_DIR="$HOME/dotfiles"

2. ASSEGNAZIONE ICONE (METADATI GIO)
Esegui nel terminale:
gio set ~/bin metadata::custom-icon-name folder-script
gio set ~/dotfiles metadata::custom-icon-name folder-git

3. REFRESH SISTEMA E THUNAR
Esegui nel terminale:
sudo gtk-update-icon-cache /usr/share/icons/Lila_HD_Blue/
thunar -q

4. BARRA LATERALE THUNAR
Trascina fisicamente le cartelle bin e dotfiles nella colonna sinistra di Thunar per creare i segnalibri con le nuove icone.
