#!/usr/bin/env bash

# =====================================================================
# FEDORA REBORN - SCRIPT COMPLETO (Versione Anti-Errore)
# Per configurare Disco Esterno, SELinux e Dotfiles
# =====================================================================

# Gestione errori: spiega cosa succede se lo script si ferma
trap_error() {
    echo ""
    echo "❌ ERRORE CRITICO alla riga $1"
    echo "Lo script si è fermato. Verifica se il disco è collegato correttamente."
    exit 1
}

set -e
trap 'trap_error $LINENO' ERR

echo "--- 1. CONFIGURAZIONE DISCO (fstab) ---"
UUID="40175288-0055-44da-9612-c080122d04c8"
MOUNT_POINT="/media/ilnanny/dati-linux"

# Crea la cartella di destinazione se non esiste
sudo mkdir -p "$MOUNT_POINT"

# Pulisce fstab da vecchie configurazioni problematiche (come il context fisso)
if grep -q "$UUID" /etc/fstab; then
    echo "Aggiorno la riga esistente in /etc/fstab..."
    sudo sed -i "s|.*$UUID.*|UUID=$UUID  $MOUNT_POINT  ext4  defaults,noatime,rw,nofail  0  2|" /etc/fstab
else
    echo "Aggiungo nuova riga in /etc/fstab..."
    echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults,noatime,rw,nofail  0  2" | sudo tee -a /etc/fstab
fi

# Tenta il mount. Se è già montato non si ferma.
sudo mount "$MOUNT_POINT" || echo "Il disco è già montato, procedo..."

echo "--- 2. ADDOMESTICARE SELINUX ---"
# Spieghiamo a Fedora che quel disco è 'amico' (Equivalenza alla Home)
echo "Registrazione del percorso nel database di sicurezza..."
sudo semanage fcontext -a -e /home "$MOUNT_POINT" || echo "Regola già presente."

# Applichiamo le etichette corrette ai file
echo "Applicazione etichette SELinux (attendere...)"
sudo restorecon -R -v "$MOUNT_POINT"

echo "--- 3. RESET CONFIGURAZIONI XFCE DI DEFAULT ---"
# Rimuoviamo le cartelle reali create da Fedora per far posto ai tuoi link
TARGETS=("xfce4" "Thunar" "geany" "gtk-3.0")

for t in "${TARGETS[@]}"; do
    CONF_PATH="$HOME/.config/$t"
    if [ -d "$CONF_PATH" ] && [ ! -L "$CONF_PATH" ]; then
        echo "Backup/Rimozione cartella di default: $t"
        mv "$CONF_PATH" "${CONF_PATH}_bak_$(date +%H%M%S)"
    fi
done

echo "--- 4. CREAZIONE SYMLINK AI TUOI DOTFILES ---"
# Creiamo i collegamenti verso il tuo 'coltellino svizzero'
DOT_SRC="$MOUNT_POINT/dotfiles"

for t in "${TARGETS[@]}"; do
    if [ -d "$DOT_SRC/$t" ]; then
        echo "Collego: $t"
        ln -sv "$DOT_SRC/$t" "$HOME/.config/$t"
    else
        echo "⚠️  Attenzione: Cartella $t non trovata in $DOT_SRC"
    fi
done

echo ""
echo "✅ TUTTO FATTO!"
echo "Ora puoi installare lo script master e poi riavvia."
