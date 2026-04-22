#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Arch Installation - Fase 1. Rilevamento dischi, gestione 
# partizioni EFI/Root e preparazione dei punti di mount per il chroot.
#
# Autore: ilnanny 2026
# Mail  : ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

# ─── Colori ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }

# ─── Variabili ───────────────────────────────────────────────────────────────
DISK="/dev/sda"
EFI_PART="${DISK}1"
ARCH_PART="${DISK}3"
MOUNTPOINT="/mnt/arch"

# ─── Root check ──────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 01-partizioni.sh"

# ─── Banner ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        ARCH LINUX INSTALL — 01 PARTIZIONI               ║"
echo "║   Huawei Matebook D | i5-10210U | SSD esterno /dev/sda  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# ─── 1. Rilevamento disco ─────────────────────────────────────────────────────
info "Rilevamento layout disco ${DISK}..."
if ! lsblk -p "${DISK}" &>/dev/null; then
    error "Disco ${DISK} non trovato. Controlla la connessione del SSD esterno."
fi

echo ""
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL "${DISK}"
echo ""

# Verifica partizioni attese
for part in "${EFI_PART}" "${ARCH_PART}"; do
    if [[ ! -b "${part}" ]]; then
        error "Partizione ${part} non trovata. Layout disco inatteso."
    fi
done
ok "Layout disco verificato: sda1=EFI  sda2=MX  sda3=Arch  sda4=Void"

# ─── 2. Verifica/Formattazione partizione EFI ────────────────────────────────
info "Controllo partizione EFI (${EFI_PART})..."
EFI_FS=$(lsblk -no FSTYPE "${EFI_PART}" 2>/dev/null || true)

if [[ "${EFI_FS}" == "vfat" ]]; then
    ok "EFI già formattata come FAT32 — non la toccheremo (condivisa con MX/Void)."
else
    warn "EFI non sembra FAT32 (trovato: '${EFI_FS:-vuoto}')"
    echo -e "${YELLOW}ATTENZIONE: formattare l'EFI cancellerà i bootloader di MX e Void!${RESET}"
    read -rp "Vuoi formattare ${EFI_PART} come FAT32? [s/N] " resp
    if [[ "${resp,,}" == "s" ]]; then
        info "Formattazione ${EFI_PART} come FAT32..."
        mkfs.fat -F32 -n "EFI" "${EFI_PART}"
        ok "EFI formattata."
    else
        error "EFI non formattata e non riconosciuta come FAT32. Abort."
    fi
fi

# ─── 3. Verifica/Formattazione partizione Arch ───────────────────────────────
info "Controllo partizione Arch (${ARCH_PART})..."
ARCH_FS=$(lsblk -no FSTYPE "${ARCH_PART}" 2>/dev/null || true)

if [[ "${ARCH_FS}" == "ext4" ]]; then
    warn "sda3 già formattata ext4."
    read -rp "Riformattare ${ARCH_PART} (cancella tutto)? [s/N] " resp2
    if [[ "${resp2,,}" == "s" ]]; then
        mkfs.ext4 -L "arch" "${ARCH_PART}"
        ok "sda3 riformattata."
    else
        ok "Tengo il filesystem esistente su sda3."
    fi
else
    info "Formattazione ${ARCH_PART} come ext4..."
    mkfs.ext4 -L "arch" "${ARCH_PART}"
    ok "sda3 formattata ext4."
fi

# ─── 4. Mount partizioni ─────────────────────────────────────────────────────
info "Creazione mountpoint ${MOUNTPOINT}..."
mkdir -p "${MOUNTPOINT}"

# Smonta se già montato
if mountpoint -q "${MOUNTPOINT}"; then
    warn "${MOUNTPOINT} già montato — smonto prima..."
    umount -R "${MOUNTPOINT}"
fi

info "Mount sda3 → ${MOUNTPOINT}..."
mount "${ARCH_PART}" "${MOUNTPOINT}"
ok "sda3 montata su ${MOUNTPOINT}"

info "Mount EFI → ${MOUNTPOINT}/boot/efi..."
mkdir -p "${MOUNTPOINT}/boot/efi"
mount "${EFI_PART}" "${MOUNTPOINT}/boot/efi"
ok "EFI montata su ${MOUNTPOINT}/boot/efi"

# ─── 5. Riepilogo mount ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Mount attivi:${RESET}"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "${DISK}"
echo ""

# ─── 6. Ottimizzazione mirror (opzionale) ────────────────────────────────────
if command -v reflector &>/dev/null; then
    info "Aggiornamento mirror con reflector (Italia/Europa)..."
    reflector --country Italy,Germany,France \
              --protocol https \
              --sort rate \
              --latest 10 \
              --save /etc/pacman.d/mirrorlist
    ok "Mirrorlist aggiornato."
else
    warn "reflector non trovato. Usa manualmente rankmirrors se necessario."
fi

# ─── 7. Salva variabili per gli script successivi ────────────────────────────
cat > /tmp/arch-install-vars.env <<EOF
DISK="${DISK}"
EFI_PART="${EFI_PART}"
ARCH_PART="${ARCH_PART}"
MOUNTPOINT="${MOUNTPOINT}"
EOF
ok "Variabili salvate in /tmp/arch-install-vars.env"

echo ""
echo -e "${GREEN}${BOLD}✔ Script 01 completato. Prosegui con: sudo bash 02-base.sh${RESET}"
