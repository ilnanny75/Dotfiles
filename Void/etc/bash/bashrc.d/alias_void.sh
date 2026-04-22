#!/bin/bash
#================================================
#    O.S.      : Void Linux
#    Author    : Cristian Pozzessere = ilnanny
#    Progetto  : Alias 2026 per Void Linux
#    GitHub    : https://github.com/ilnanny75
#================================================

# --- GESTIONE SERVIZI (runit) ---
alias sv="sudo sv"

# --- LOGICAL VOLUME MANAGEMENT (LVM) ---
alias lvs="sudo lvs"
alias vgs="sudo vgs"
alias vgdisplay="sudo vgdisplay"

# --- XBPS: COMANDI DI BASE ---
alias install="sudo xbps-install -S"
alias update="sudo xbps-install -Su"
alias remove="sudo xbps-remove -R"
alias search="xbps-query -Rs"
alias query="xbps-query -f"
alias reconfigure="sudo xbps-reconfigure"

# --- MANUTENZIONE E PULIZIA ---
alias ccache="sudo xbps-remove -O"
alias orphans="sudo xbps-remove -o"
alias pkg-check="sudo xbps-pkgdb -a"
alias lock="sudo xbps-pkgdb -m hold"
alias unlock="sudo xbps-pkgdb -m unhold"

