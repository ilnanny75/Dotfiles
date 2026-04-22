#!/bin/bash

# Controllo privilegi
if [[ $EUID -ne 0 ]]; then
   echo "Errore: Esegui lo script con sudo."
   exit 1
fi

echo "--- Installazione Logseq via Flatpak ---"

# 1. Identificazione Distro e Installazione Flatpak
if command -v dnf >/dev/null 2>&1; then
    echo "Rilevata Fedora. Controllo Flatpak..."
    dnf install -y flatpak
elif command -v apt >/dev/null 2>&1; then
    echo "Rilevata Debian. Controllo Flatpak..."
    apt update && apt install -y flatpak
elif command -v pacman >/dev/null 2>&1; then
    echo "Rilevata Arch. Controllo Flatpak..."
    pacman -Sy --noconfirm flatpak
else
    echo "Distro non supportata direttamente dallo script. Installa flatpak manualmente."
    exit 1
fi

# 2. Aggiunta Repository Flathub (indispensabile)
echo "Aggiunta del repository Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 3. Installazione Logseq
# Nota: flatpak install -y accetta automaticamente le domande
echo "Installazione di Logseq in corso (potrebbe volerci un po')..."
flatpak install -y flathub com.logseq.Logseq

echo "-----------------------------------------------------------"
echo "Installazione completata!"
echo "Puoi avviare Logseq dal tuo menu applicazioni o con:"
echo "flatpak run com.logseq.Logseq"
echo "-----------------------------------------------------------"