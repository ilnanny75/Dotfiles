#!/bin/bash

# Controllo privilegi
if [[ $EUID -ne 0 ]]; then
   echo "Errore: Esegui lo script con sudo."
   exit 1
fi

FONT_SIZE=32
FONT_NAME="DejaVuSansMono"

# 1. Rilevamento Distro e Tool
if command -v dnf >/dev/null 2>&1; then
    DISTRO="fedora"
    MKFONT_CMD="grub2-mkfont"
    PKG_SUGGEST="sudo dnf install grub2-tools fontconfig"
elif command -v apt >/dev/null 2>&1; then
    DISTRO="debian"
    MKFONT_CMD="grub-mkfont"
    PKG_SUGGEST="sudo apt install grub-common fonts-dejavu-core"
elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
    MKFONT_CMD="grub-mkfont"
    PKG_SUGGEST="sudo pacman -S grub dejavu-otf-fonts"
else
    DISTRO="unknown"
    MKFONT_CMD="grub-mkfont"
    PKG_SUGGEST="installa i pacchetti relativi a grub-utils e dejavu fonts"
fi

# Controllo se il binario per convertire i font esiste
if ! command -v $MKFONT_CMD >/dev/null 2>&1; then
    echo "--------------------------------------------------------"
    echo "ERRORE: Strumento '$MKFONT_CMD' non trovato."
    echo "Per continuare, installa i pacchetti necessari con:"
    echo "  $PKG_SUGGEST"
    echo "--------------------------------------------------------"
    exit 1
fi

# 2. Ricerca del file TTF sorgente
TTF_PATH=$(find /usr/share/fonts -name "${FONT_NAME}.ttf" | head -n 1)

if [ -z "$TTF_PATH" ]; then
    echo "Errore: Font ${FONT_NAME}.ttf non trovato nel sistema."
    echo "Assicurati di aver installato i font DejaVu."
    exit 1
fi

# 3. Identificazione directory GRUB
if [ -d /boot/grub2 ]; then
    GRUB_DIR="/boot/grub2"
    UPDATE_CMD="grub2-mkconfig -o /boot/grub2/grub.cfg"
else
    GRUB_DIR="/boot/grub"
    if command -v update-grub >/dev/null 2>&1; then
        UPDATE_CMD="update-grub"
    else
        UPDATE_CMD="grub-mkconfig -o /boot/grub/grub.cfg"
    fi
fi

echo "Ottimo, strumenti trovati. Configuro GRUB in Full HD (1920x1080)..."

# 4. Creazione Font PF2
mkdir -p "$GRUB_DIR/fonts"
PF2_FILE="$GRUB_DIR/fonts/${FONT_NAME}${FONT_SIZE}.pf2"
$MKFONT_CMD -s $FONT_SIZE -o "$PF2_FILE" "$TTF_PATH"

# 5. Backup e Modifica /etc/default/grub
cp /etc/default/grub /etc/default/grub.bak
sed -i '/GRUB_FONT=/d' /etc/default/grub
sed -i '/GRUB_TERMINAL_OUTPUT=/d' /etc/default/grub
sed -i '/GRUB_GFXMODE=/d' /etc/default/grub
sed -i '/GRUB_DISABLE_OS_PROBER=/d' /etc/default/grub

cat <<EOF >> /etc/default/grub
GRUB_FONT="$PF2_FILE"
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_GFXMODE="1920x1080,auto"
GRUB_DISABLE_OS_PROBER="false"
EOF

# 6. Rigenerazione Finale
$UPDATE_CMD

echo "--- Script completato con successo! ---"
echo "Al prossimo riavvio il menu sarà grande e leggibile."