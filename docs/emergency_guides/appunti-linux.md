# 🐧 Appunti Linux & Memo Rapidi

## 1. Ripristino GRUB (Bootloader)
Comandi rapidi per reinstallare il bootloader in base alla distro:

- **Debian/Ubuntu**: sudo dpkg-reconfigure grub-efi-amd64
- **Fedora**: sudo dnf reinstall grub2-efi shim
- **Arch**: sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

## 2. Gestione ISO e USB (Ventoy/Rsync)
Procedura sicura per spostare ISO su chiavette multiboot.

# 1. Verifica integrità (Sostituisci il nome del file)
sha256sum Fedora-Xfce-Live-ISO.iso

# 2. Spostamento con rsync (mostra progresso e velocità)
rsync -avh --progress Fedora-Xfce-Live-ISO.iso /media/$USER/Ventoy/ && sync

# 3. Smontaggio sicuro
umount /media/$USER/Ventoy

## 3. Promemoria Git (Workflow Standard)
- git status          : Controlla file modificati (Prima di iniziare)
- git pull --rebase   : Scarica aggiornamenti (Sempre prima di lavorare)
- git add .           : Prepara i file (Dopo una modifica)
- git commit -m ".."  : Salva localmente (Per confermare il lavoro)
- git push            : Invia su GitHub (Per aggiornare il sito)
- git log --oneline   : Cronologia breve (Per vedere i lavori fatti)
- git branch -M main  : Rinomina ramo in main (Se vedi ancora "master")

## 4. Creazione Moduli SELinux (Fedora)
Da usare quando un processo viene bloccato ingiustamente. Sostituisci 'NOMEPROCESSO'.

# Estrae l'errore dai log e genera il modulo (.te e .pp)
sudo ausearch -c 'NOMEPROCESSO' --raw | audit2allow -M mio-modulo

# Installa il modulo nel database di sistema
sudo semodule -i mio-modulo.pp

# Verifica caricamento
sudo semodule -l | grep mio-modulo

# Pulizia file temporanei
rm mio-modulo.te mio-modulo.pp

## 5. Disabilitare dnfdragora-updater (Fedora)
Per velocizzare l'avvio ed evitare notifiche insistenti.

# Assicura il possesso della cartella autostart
sudo chown -R $USER:$USER ~/.config/autostart

# Copia il file desktop nella config locale
cp /etc/xdg/autostart/org.mageia.dnfdragora-updater.desktop ~/.config/autostart/

# Disabilita l'esecuzione automatica
echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/org.mageia.dnfdragora-updater.desktop
echo "Hidden=true" >> ~/.config/autostart/org.mageia.dnfdragora-updater.desktop
