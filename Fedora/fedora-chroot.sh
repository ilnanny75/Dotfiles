#!/bin/bash

# --- CONFIGURAZIONE ---
# Cambia 'sda4' se la partizione di Fedora dovesse cambiare in futuro
PARTIZIONE="/dev/sda4"
MOUNT_POINT="/mnt/fedora"

# Funzione per montare
mount_fedora() {
    echo "--- Montaggio di Fedora ($PARTIZIONE) in corso ---"
    sudo mkdir -p $MOUNT_POINT
    sudo mount $PARTIZIONE $MOUNT_POINT
    
    # Mount dei filesystem di sistema necessari
    for i in /dev /dev/pts /proc /sys /run; do
        sudo mount --bind $i $MOUNT_POINT$i
    done
    
    # Copia DNS per internet nel chroot
    sudo cp /etc/resolv.conf $MOUNT_POINT/etc/resolv.conf
    
    echo "Fatto! Ora puoi entrare con: sudo chroot $MOUNT_POINT /bin/bash"
}

# Funzione per smontare
umount_fedora() {
    echo "--- Smontaggio in corso (Lazy Umount) ---"
    sudo umount -l $MOUNT_POINT/dev/pts 2>/dev/null
    sudo umount -l $MOUNT_POINT/dev 2>/dev/null
    sudo umount -l $MOUNT_POINT/proc 2>/dev/null
    sudo umount -l $MOUNT_POINT/sys 2>/dev/null
    sudo umount -l $MOUNT_POINT/run 2>/dev/null
    sudo umount -l $MOUNT_POINT 2>/dev/null
    echo "Tutto smontato correttamente."
}

# Scelta dell'azione
case "$1" in
    mount)
        mount_fedora
        ;;
    umount)
        umount_fedora
        ;;
    *)
        echo "Utilizzo: $0 {mount|umount}"
        exit 1
esac
