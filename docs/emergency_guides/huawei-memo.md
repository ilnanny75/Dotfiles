# 💻 PROFILO HARDWARE & MANUALE TECNICO MASTER

## 0. INFORMAZIONI DI SISTEMA (HUAWEI MATEBOOK D)
- **Marca/Modello**: HUAWEI MateBook D (BOHB-WAX9)
- **CPU**: Intel Core i5-10210U (4 core / 8 thread)
- **RAM**: 8 GB (7872 MB)
- **GPU**: Intel UHD Graphics (CometLake-U GT2)
- **Storage**: SSD Crucial (sCT240BX500SSD1) 240 GB

---

## 1. CHROOT UNIVERSALE (RIPRISTINO SISTEMA)
# Identifica ROOT e EFI con lsblk. Se Fedora/Btrfs: mount -o subvol=root /dev/sdX /mnt

# A. Montaggio Base
mount /dev/sdX2 /mnt          # ROOT
mount /dev/sdX1 /mnt/boot/efi # EFI

# B. Bind filesystem & DNS
for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
cp /etc/resolv.conf /mnt/etc/resolv.conf

# C. Entrare nel sistema
# Arch: arch-chroot /mnt | Altre: chroot /mnt /bin/bash

# D. Ripristino GRUB
# Debian: update-grub && grub-install /dev/sdX
# Arch: grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB && grub-mkconfig -o /boot/grub/grub.cfg
# Fedora BIOS: grub2-mkconfig -o /boot/grub2/grub.cfg
# Fedora UEFI: grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# E. Uscita e Smontaggio Forzato
exit
umount -R /mnt
# Se busy: sudo fuser -kvm /mnt && sudo umount -l /mnt

---

## 2. VS CODE & AI (MCP SERVER)
- Fix Permessi: sudo chown -R $USER:$USER ~/inkmcp
- Emergenza Server: pkill -f mcp_server.py
- Scorciatoie: Ctrl+ò (Terminale), Ctrl+P (Cerca), Ctrl+Shift+V (Anteprima)

---

## 3. RESET PERMESSI DOTFILES (EXT4)
# Eseguire nella cartella dei dotfiles
sudo chown -R $USER:$USER . && \
find . -type d -exec chmod 755 {} + && \
find . -type f -exec chmod 644 {} + && \
find . -name "*.sh" -exec chmod +x {} + && \
sudo chown -hR $USER:$USER .

---

## 4. RESIZE FONT GRUB (HiDPI)
# DEBIAN:
sudo grub-mkfont --output=/boot/grub/fonts/DejaVu32.pf2 --size=32 /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
# FEDORA:
sudo grub2-mkfont --output=/boot/grub2/fonts/DejaVu32.pf2 --size=32 /usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf

---

## 5. TASTIERA MATEBOOK & COMPOSE
# Config /etc/default/keyboard: XKBOPTIONS="lv3:ralt_switch,compose:caps,caps:none"
# Applica: setxkbmap -model pc105 -layout it -option "lv3:ralt_switch,compose:caps,caps:none"

# Sequenze Compose (~/.XCompose):
# Compose + * + * -> ∗ (Asterisco Operatore)
# Compose + E + '  -> È (E maiuscola accentata)
# Compose + - + >  -> → (Freccia)

---

## 6. MEMO RAPIDI LINUX
- ISO su USB: rsync -avh --progress file.iso /media/$USER/Ventoy/ && sync
- Git: git status | git pull --rebase | git add . | git commit -m ".." | git push
- SELinux: sudo ausearch -c 'PROCESSO' --raw | audit2allow -M modulo && sudo semodule -i modulo.pp
