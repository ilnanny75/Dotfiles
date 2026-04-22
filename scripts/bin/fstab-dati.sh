#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Setup interattivo della partizione Dati. Verifica l'UUID, 
# crea il mount point e aggiorna /etc/fstab con backup di sicurezza.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# Definiamo il punto di mount e l'UUID
MOUNT_POINT="/media/ilnanny/dati-linux"
UUID="40175288-0055-44da-9612-c080122d04c8"

echo "Controllo se la cartella esiste..."
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creazione cartella $MOUNT_POINT in corso..."
    sudo mkdir -p "$MOUNT_POINT"
fi

echo "Tentativo di montaggio della partizione dati..."
sudo mount -U "$UUID" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "Successo! Disco montato in $MOUNT_POINT"
    # Opzionale: sistema i permessi al volo
    sudo chown -R $USER:$USER "$MOUNT_POINT"
else
    echo "Errore: Assicurati che l'SSD sia collegato."
fi
echo " [OK] Disco trovato correttamente."

# 2. Gestione Punto di Mount
if [ ! -d "$MOUNT_POINT" ]; then
    echo "[*] Il punto di mount $MOUNT_POINT non esiste. Lo creo?"
    read -p "    Procedere? (s/n): " confirm
    if [[ $confirm == [sS] ]]; then
        sudo mkdir -p "$MOUNT_POINT"
        echo " [OK] Cartella creata."
    else
        echo " [!] Operazione annullata."
        exit 1
    fi
fi

# 3. Backup di fstab
echo "[*] Creazione backup di /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak

# 4. Scrittura in fstab (Pulizia e Nuova riga)
echo "[*] Aggiornamento /etc/fstab..."
# Rimuove righe che contengono il mount point o l'UUID per evitare duplicati
sudo sed -i "\| $MOUNT_POINT |d" /etc/fstab
sudo sed -i "/$UUID_DATI/d" /etc/fstab

LINEA_FSTAB="UUID=$UUID_DATI  $MOUNT_POINT  ext4  defaults,noatime,x-gvfs-show  0  2"

echo "$LINEA_FSTAB" | sudo tee -a /etc/fstab > /dev/null
echo " [OK] Configurazione fstab scritta."

# 5. Montaggio
echo "[*] Tentativo di montaggio..."
sudo umount "$MOUNT_POINT" 2>/dev/null
if sudo mount -a; then
    echo " [OK] Partizione montata con successo."
else
    echo " [!] Errore nel montaggio. Verifica il file /etc/fstab."
    exit 1
fi

# 6. Fix Permessi Ricorsivo
echo "[*] Vuoi diventare proprietario di tutti i file in $MOUNT_POINT?"
read -p "    Procedere? (s/n): " confirm_perm
if [[ $confirm_perm == [sS] ]]; then
    sudo chown -R $(id -u):$(id -g) "$MOUNT_POINT"
    echo " [OK] Permessi impostati correttamente."
fi

echo "===================================================="
echo "   CONFIGURAZIONE COMPLETATA!"
echo "===================================================="
