#!/bin/bash
## ═══════════════════════════════════════════════════════════════════
# Nota: Coltellino svizzero per riparare EFI
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Controllo Root ---
[[ $EUID -ne 0 ]] && echo "Errore: usa sudo!" && exit 1

echo "--------------------------------------------------------"
echo "   SUPER-RESCUE: EFI, FSTAB & GRUB (Live & Local)       "
echo "--------------------------------------------------------"

# 1. Scelta della partizione ROOT da riparare
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT
echo -e "\n[?] Quale partizione ROOT vuoi riparare? (es. sda2)"
read -p "/dev/" ROOT_PART
TARGET_ROOT="/dev/$ROOT_PART"

# 2. Scelta partizione EFI
echo "[?] Quale partizione EFI vuoi usare? (es. sda1)"
read -p "/dev/" EFI_PART
TARGET_EFI="/dev/$EFI_PART"
NEW_EFI_UUID=$(blkid -s UUID -o value $TARGET_EFI)

# 3. Punto di mount temporaneo per la riparazione
MNT="/mnt/rescue"
mkdir -p $MNT
mount $TARGET_ROOT $MNT

# 4. AGGIORNAMENTO FSTAB (sul disco, non nella live)
echo "[+] Aggiornamento fstab in $TARGET_ROOT..."
sed -i.bak "s|UUID=[A-Z0-9x-]\{4,36\}\s\+/boot/efi|UUID=$NEW_EFI_UUID /boot/efi|g" $MNT/etc/fstab

# 5. PREPARAZIONE CHROOT (per far credere allo script di essere dentro il sistema)
echo "[+] Preparazione ambiente chroot..."
mount $TARGET_EFI $MNT/boot/efi
for i in /dev /dev/pts /proc /sys /run; do mount -B $i $MNT$i; done

# 6. REINSTALLAZIONE GRUB (Eseguita "dentro" il sistema target)
echo "[?] Su quale DISCO fisico installo GRUB? (es. sda)"
read -p "/dev/" GRUB_DISK
DISK_PATH="/dev/$GRUB_DISK"

echo "[+] Esecuzione riparazione interna..."
chroot $MNT /bin/bash <<EOF
  # Controllo se systemd è presente prima di dare comandi systemd
  if [ -d /run/systemd/system ]; then
      systemctl daemon-reload
  fi
  
  grub-install $DISK_PATH
  update-grub
EOF

# 7. PULIZIA
echo "[+] Smontaggio e pulizia..."
umount -R $MNT
echo -e "\n[OK] Riparazione completata. Ora puoi riavviare."
