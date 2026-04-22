#!/bin/bash
# ════════════════════════════════════════════
# Nota : Installa vscode su Fedora
#
#  Autore: ilnanny 2026
#  Mail  : ilnannyhack@gmail.com
#  GitHub: https://github.com/ilnanny75
# ════════════════════════════════════════════

# Controllo se l'utente ha i permessi di root
if [ "$EUID" -ne 0 ]; then 
  echo "Per favore, esegui lo script con sudo."
  exit
fi

echo "--- Inizio installazione Visual Studio Code ---"

# 1. Importa la chiave GPG di Microsoft
echo "Importazione della chiave GPG..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# 2. Crea il file del repository
echo "Configurazione del repository VS Code..."
cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# 3. Aggiorna la cache e installa
echo "Aggiornamento dei pacchetti e installazione di 'code'..."
dnf check-update
sudo dnf install -y code

echo "--- Installazione completata con successo! ---"
