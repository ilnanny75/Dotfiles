#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Lila HD - Fedora Native Packager (RPM) - Terminal Version
# ═══════════════════════════════════════════════════════════════════

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKDIR"

# Controllo file spec
if [ ! -f "lila-hd.spec" ]; then
    echo -e "\e[31mErrore: lila-hd.spec non trovato!\e[0m"
    exit 1
fi

echo -e "\e[34m[1/3]\e[0m Creazione directory di build..."
mkdir -p ~/rpmbuild/{SOURCES,SPECS}

echo -e "\e[34m[2/3]\e[0m Compressione sorgenti (lila-hd-icon-theme-2026.tar.gz)..."
tar --exclude=".git*" -cvzf ~/rpmbuild/SOURCES/lila-hd-icon-theme-2026.tar.gz Lila_HD*

echo -e "\e[34m[3/3]\e[0m Avvio rpmbuild nativo..."
cp "lila-hd.spec" ~/rpmbuild/SPECS/

if rpmbuild -ba ~/rpmbuild/SPECS/lila-hd.spec; then
    mkdir -p EXPORT_FEDORA
    cp ~/rpmbuild/RPMS/noarch/*.rpm EXPORT_FEDORA/
    echo -e "\e[32m✔ RPM creato con successo in EXPORT_FEDORA/\e[0m"
else
    echo -e "\e[31m✘ Errore durante la build dell'RPM.\e[0m"
    exit 1
fi
