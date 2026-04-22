#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Void Linux Chroot Installer. Automatizza l'installazione di 
# Void da un'altra distro. Gestisce il mounting, il bootstrap di XBPS, 
# la configurazione di fstab, user, kernel e i servizi Runit.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════
#
#  SCHEMA PARTIZIONI :
#  /dev/sda1  256M  vfat   EFI condivisa    UUID=5FCE-81..
#  /dev/sda2  53.7G ext4   Debian root
#  /dev/sda3  53.7G ext4   Arch Linux root
#  /dev/sda4  53.7G ext4   Void Linux root  UUID=2e730..
#  /dev/sda5  62.2G ext4   dati-linux       UUID=401752..
#
# ═══════════════════════════════════════════════════════════════════

# --- COLORI ---
V="\e[32m"; R="\e[31m"; C="\e[36m"; G="\e[33m"; B="\e[1m"; RESET="\e[0m"
ok()   { echo -e "${V}✅ $*${RESET}"; }
info() { echo -e "${C}ℹ️  $*${RESET}"; }
warn() { echo -e "${G}⚠️  $*${RESET}"; }
err()  { echo -e "${R}❌ $*${RESET}"; exit 1; }

MOUNT=/mnt/void
TARBALL="void-x86_64-ROOTFS-20250202.tar.xz"
TARBALL_URL="https://repo-default.voidlinux.org/live/current/${TARBALL}"

# ═══════════════════════════════════════════════════════════════════
# FASE 0 — VERIFICA SISTEMA HOST
# ═══════════════════════════════════════════════════════════════════
info "Verifica UEFI..."
[ -d /sys/firmware/efi ] || err "Sistema non UEFI. Script pensato per UEFI."
ok "UEFI rilevato."

info "Verifica tools necessari..."
for cmd in wget tar chroot blkid mount grub-install; do
    command -v "$cmd" &>/dev/null || err "Tool mancante: $cmd"
done
ok "Tutti i tools presenti."

info "Verifica connessione internet..."
ping -c1 -W3 8.8.8.8 &>/dev/null || err "Nessuna connessione internet."
ok "Internet ok."

# ═══════════════════════════════════════════════════════════════════
# FASE 1 — SELEZIONE PARTIZIONE
# ═══════════════════════════════════════════════════════════════════
echo ""
info "Partizioni disponibili:"
lsblk -f
echo ""
read -p "  Inserisci la partizione di destinazione per Void (es. /dev/sda4): " VOID_PART
[ -b "$VOID_PART" ] || err "Partizione $VOID_PART non trovata."

read -p "  Inserisci la partizione EFI (es. /dev/sda1): " EFI_PART
[ -b "$EFI_PART" ] || err "Partizione EFI $EFI_PART non trovata."

read -p "  Inserisci la partizione dati-linux (es. /dev/sda5, invio per saltare): " DATI_PART
read -p "  Inserisci la partizione Windows NTFS (es. /dev/nvme0n1p4, invio per saltare): " WIN_PART

# Recupero UUID
UUID_ROOT=$(blkid -s UUID -o value "$VOID_PART")
UUID_EFI=$(blkid -s UUID -o value "$EFI_PART")
[ -n "$UUID_ROOT" ] || err "UUID root non trovato."
[ -n "$UUID_EFI"  ] || err "UUID EFI non trovato."
[ -n "$DATI_PART" ] && UUID_DATI=$(blkid -s UUID -o value "$DATI_PART")
[ -n "$WIN_PART"  ] && UUID_WIN=$(blkid -s UUID -o value "$WIN_PART")

ok "UUID ROOT : $UUID_ROOT"
ok "UUID EFI  : $UUID_EFI"
[ -n "$UUID_DATI" ] && ok "UUID DATI  : $UUID_DATI"
[ -n "$UUID_WIN"  ] && ok "UUID WIN   : $UUID_WIN"

# ═══════════════════════════════════════════════════════════════════
# FASE 2 — CONFIGURAZIONE SISTEMA
# ═══════════════════════════════════════════════════════════════════
read -p "  Hostname (es. void-ilnanny): " HOSTNAME
read -p "  Nome utente (es. ilnanny): " USERNAME
read -p "  Timezone (es. Europe/Rome): " TIMEZONE
TIMEZONE=${TIMEZONE:-Europe/Rome}

# ═══════════════════════════════════════════════════════════════════
# FASE 3 — TARBALL
# ═══════════════════════════════════════════════════════════════════
echo ""
echo -e "  ${C}Tarball Void:${RESET}"
echo -e "  ${V}1)${RESET} Scarica automaticamente"
echo -e "  ${V}2)${RESET} Usa file esistente"
read -p "  Scegli: " TARBALL_SCELTA

case $TARBALL_SCELTA in
    1)
        info "Download tarball..."
        wget -c "$TARBALL_URL" -O ~/"$TARBALL" || err "Download fallito."
        TARBALL_PATH=~/"$TARBALL"
        ;;
    2)
        read -p "  Percorso completo del tarball: " TARBALL_PATH
        [ -f "$TARBALL_PATH" ] || err "File non trovato: $TARBALL_PATH"
        ;;
    *) err "Scelta non valida." ;;
esac

# ═══════════════════════════════════════════════════════════════════
# FASE 4 — MOUNT E ESTRAZIONE
# ═══════════════════════════════════════════════════════════════════
info "Creazione punto di mount e montaggio..."
sudo mkdir -p "$MOUNT"
sudo mount "$VOID_PART" "$MOUNT" || err "Mount $VOID_PART fallito."

info "Estrazione tarball (potrebbe richiedere qualche minuto)..."
sudo tar xpf "$TARBALL_PATH" -C "$MOUNT" || err "Estrazione fallita."
ok "Tarball estratto."

info "Bind mount filesystem virtuali..."
sudo mount --bind /proc              "$MOUNT/proc"
sudo mount --bind /sys               "$MOUNT/sys"
sudo mount --bind /dev               "$MOUNT/dev"
sudo mount --bind /dev/pts           "$MOUNT/dev/pts"
sudo mount --bind /run               "$MOUNT/run"
sudo mount --bind /sys/firmware/efi/efivars "$MOUNT/sys/firmware/efi/efivars"

info "Mount partizione EFI..."
sudo mkdir -p "$MOUNT/boot/efi"
sudo mount "$EFI_PART" "$MOUNT/boot/efi" || err "Mount EFI fallito."

info "Copia resolv.conf per internet nel chroot..."
sudo cp /etc/resolv.conf "$MOUNT/etc/resolv.conf"

# ═══════════════════════════════════════════════════════════════════
# FASE 5 — SCRIPT DA ESEGUIRE DENTRO IL CHROOT
# ═══════════════════════════════════════════════════════════════════
info "Generazione script interno chroot..."

sudo tee "$MOUNT/root/void-setup.sh" > /dev/null << CHROOT_EOF
#!/bin/bash
export PS1="(void-chroot) # "
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Aggiornamento xbps e sistema
xbps-install -Su xbps
xbps-install -Su

# Pacchetti essenziali
xbps-install -y linux linux-headers base-devel grub grub-x86_64-efi efibootmgr os-prober \\
    NetworkManager network-manager-applet git ntfs-3g wget curl \\
    xorg-minimal xorg-input-drivers xorg-video-drivers \\
    mesa-intel-dri intel-video-accel \\
    xfce4 Thunar thunar-archive-plugin thunar-volman \\
    xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin \\
    xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-notifyd \\
    xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-taskmanager \\
    xfce4-whiskermenu-plugin xfce4-power-manager xfce4-xkb-plugin \\
    lightdm lightdm-gtk-greeter \\
    bluez blueman \\
    pipewire wireplumber alsa-pipewire alsa-utils \\
    gvfs gvfs-mtp udisks2 polkit-gnome xfce-polkit \\
    firefox ibus ibus-gtk+3 \\
    dejavu-fonts-ttf liberation-fonts-ttf noto-fonts-ttf ttf-ubuntu-font-family fonts-roboto-ttf \\
    xorg-fonts font-misc-misc

# Locale
echo "it_IT.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales
echo "LANG=it_IT.UTF-8" > /etc/locale.conf
echo "KEYMAP=it" > /etc/rc.conf

# Hostname e timezone
echo "${HOSTNAME}" > /etc/hostname
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Password root
echo "--- Imposta password ROOT ---"
passwd

# Utente
useradd -m -G wheel,audio,video,cdrom,input,network,storage -s /bin/bash ${USERNAME}
echo "--- Imposta password utente ${USERNAME} ---"
passwd ${USERNAME}
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# fstab
mkdir -p /mnt/dati-linux /mnt/windows
cat > /etc/fstab << 'FSTAB'
# /etc/fstab - Void Linux ilnanny
UUID=${UUID_EFI}    /boot/efi       vfat    noatime,dmask=0002,fmask=0113   0 0
UUID=${UUID_ROOT}   /               ext4    noatime,rw                      0 1
$([ -n "${UUID_DATI}" ] && echo "UUID=${UUID_DATI}   /mnt/dati-linux ext4    noatime,rw                      0 2")
$([ -n "${UUID_WIN}"  ] && echo "UUID=${UUID_WIN}    /mnt/windows    ntfs-3g noauto,uid=1000,gid=1000        0 0")
tmpfs               /tmp            tmpfs   defaults,nosuid,nodev           0 0
shm                 /dev/shm        tmpfs   nosuid,nodev,noexec             0 0
FSTAB

# GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Void --recheck
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Servizi runit
ln -sf /etc/sv/dbus            /etc/runit/runsvdir/default/
ln -sf /etc/sv/NetworkManager  /etc/runit/runsvdir/default/
ln -sf /etc/sv/bluetoothd      /etc/runit/runsvdir/default/
ln -sf /etc/sv/lightdm         /etc/runit/runsvdir/default/
ln -sf /etc/sv/udisks2         /etc/runit/runsvdir/default/
ln -sf /etc/sv/polkitd         /etc/runit/runsvdir/default/

# Cache font
fc-cache -fv

# Riconfigura tutto
xbps-reconfigure -fa

echo ""
echo "✅ Setup Void completato! Esci con: exit"
CHROOT_EOF

sudo chmod +x "$MOUNT/root/void-setup.sh"

# ═══════════════════════════════════════════════════════════════════
# FASE 6 — ENTRATA IN CHROOT
# ═══════════════════════════════════════════════════════════════════
ok "Tutto pronto. Entro nel chroot..."
info "Una volta dentro, esegui: bash /root/void-setup.sh"
echo ""
sudo chroot "$MOUNT" /bin/bash

# ═══════════════════════════════════════════════════════════════════
# FASE 7 — SMONTAGGIO PULITO (dopo exit dal chroot)
# ═══════════════════════════════════════════════════════════════════
info "Smontaggio filesystem..."
sudo umount "$MOUNT/sys/firmware/efi/efivars"
sudo umount "$MOUNT/boot/efi"
sudo umount "$MOUNT/dev/pts"
sudo umount "$MOUNT/dev"
sudo umount "$MOUNT/run"
sudo umount "$MOUNT/proc"
sudo umount "$MOUNT/sys"
sudo umount "$MOUNT"

ok "Smontaggio completato. Puoi riavviare su Void!"

# Aggiorna GRUB di Debian per vedere Void
info "Aggiorno GRUB di Debian Linux per includere Void..."
sudo os-prober
sudo update-grub
ok "GRUB MX aggiornato. Ciao! 🐧"
