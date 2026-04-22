# CHROOT UNIVERSALE (Debian, Arch, Void, Fedora)
# Guida di ripristino universale per sistemi GNU/Linux

## 1. Montaggio Base
# Identifica la ROOT (es. /dev/sda2) e la EFI (es. /dev/sda1) con lsblk.
# Per Fedora/Btrfs: mount -o subvol=root /dev/sdX /mnt
mount /dev/sdX2 /mnt
mount /dev/sdX1 /mnt/boot/efi

## 2. Bind dei sistemi e DNS
# Necessario per far funzionare i processi e la rete nel chroot.
for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
cp /etc/resolv.conf /mnt/etc/resolv.conf

## 3. Entrare nel sistema
# Arch Linux: arch-chroot /mnt
# Debian/Fedora/Arch: chroot /mnt /bin/bash
# Void Linux: XBPS_ARCH=$(uname -m) chroot /mnt /bin/bash

## 4. Comandi di Ripristino Rapidi

### DEBIAN / UBUNTU
update-grub
grub-install /dev/sdX  # Disco intero, non partizione

### ARCH LINUX
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

### FEDORA
dnf reinstall grub2-efi shim
# Se UEFI:
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
# Se BIOS:
grub2-mkconfig -o /boot/grub2/grub.cfg

### VOID LINUX
xbps-reconfigure -f linux6.x  # Cambia con la tua versione

## 5. Uscita e Smontaggio
exit
umount -R /mnt

## 6. EMERGENZA: SMONTAGGIO FORZATO
# Se umount fallisce perché il target è occupato ("busy"):

# A. Trova e uccide i processi che bloccano il mount
sudo fuser -kvm /mnt

# B. Smontaggio "Pigro" (Lazy) - Libera subito il terminale
sudo umount -l /mnt

# C. Verifica se ci sono ancora punti di montaggio attivi
cat /proc/mounts | grep /mnt
