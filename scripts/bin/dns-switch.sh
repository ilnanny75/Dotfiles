#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Configura DNS Google su  linux OS (systemd,runit,sysvinit)
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════
# Controllo privilegi root
if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

# Rilevamento interfaccia attiva
INTERFACE=$(ip route get 8.8.8.8 | grep -oP 'dev \K\S+' | head -n 1)

clear
echo "--- DNS MANAGER (Debian/Arch/Void) ---"
echo "Interfaccia rilevata: $INTERFACE"
echo "1) Google DNS"
echo "2) Cloudflare DNS"
echo "3) Reset DHCP (Sblocca file)"
echo "4) Stato attuale"
read -p "Scelta: " scelta

case $scelta in
    1)
        if command -v resolvectl &> /dev/null; then
            resolvectl dns "$INTERFACE" 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844
            resolvectl flush-caches
        else
            chattr -i /etc/resolv.conf 2>/dev/null
            echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
            chattr +i /etc/resolv.conf
            echo "File /etc/resolv.conf impostato e bloccato (immutabile)."
        fi
        echo "Configurati DNS Google."
        ;;
    2)
        if command -v resolvectl &> /dev/null; then
            resolvectl dns "$INTERFACE" 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
            resolvectl flush-caches
        else
            chattr -i /etc/resolv.conf 2>/dev/null
            echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > /etc/resolv.conf
            chattr +i /etc/resolv.conf
            echo "File /etc/resolv.conf impostato e bloccato (immutabile)."
        fi
        echo "Configurati DNS Cloudflare."
        ;;
    3)
        if command -v resolvectl &> /dev/null; then
            resolvectl revert "$INTERFACE"
        else
            chattr -i /etc/resolv.conf 2>/dev/null
            echo "# DNS gestito dal sistema" > /etc/resolv.conf
            echo "File sbloccato. Il DHCP ora può scrivere."
        fi
        echo "Ripristino effettuato."
        ;;
    4)
        if command -v resolvectl &> /dev/null; then
            resolvectl status "$INTERFACE"
        else
            lsattr /etc/resolv.conf | cut -c5 | grep -q "i" && echo "[ATTENZIONE: File Bloccato]"
            cat /etc/resolv.conf
        fi
        ;;
    *)
        exit 0
        ;;
esac
