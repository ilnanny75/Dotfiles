#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Configurazione rapida GitHub. Gestisce autenticazione via 
# browser, 2FA e settaggio globale di user.name e user.email.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Identità ────────────────────────────────────────────────
readonly GIT_NAME="ilnanny75"
readonly GIT_EMAIL="cristianpozzessere@gmail.com"

# ── Colori ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

msg()  { echo -e "${CYAN}${BOLD}→${RESET} $*"; }
ok()   { echo -e "${GREEN}${BOLD}✔${RESET} $*"; }
err()  { echo -e "${RED}${BOLD}✘${RESET} $*"; exit 1; }
warn() { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }

# ── Banner ──────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"
echo -e "${BOLD}   🐙 GitHub Setup — ilnanny75${RESET}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"

# ── Rilevamento OS e installazione gh ───────────────────────
if command -v gh &>/dev/null; then
    ok "github-cli già installato: $(gh --version | head -1)"
else
    msg "Installazione github-cli..."

    if command -v xbps-install &>/dev/null; then
        sudo xbps-install -Sy github-cli
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm github-cli
    elif command -v apt &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y gh
    else
        err "Gestore pacchetti non riconosciuto. Installa 'gh' manualmente."
    fi

    ok "github-cli installato."
fi

# ── Controllo login esistente ────────────────────────────────
if gh auth status &>/dev/null; then
    warn "Sei già autenticato su GitHub:"
    gh auth status
    echo ""
    read -rp "$(echo -e "${YELLOW}Vuoi ri-autenticarti? (s/N): ${RESET}")" risposta
    [[ "$risposta" =~ ^[Ss]$ ]] || { ok "Nessuna modifica. Uscita."; exit 0; }
fi

# ── Autenticazione via browser + 2FA ────────────────────────
echo ""
msg "Avvio autenticazione GitHub via browser..."
echo -e "  ${YELLOW}→ Si aprirà una pagina web: inserisci il codice mostrato${RESET}"
echo -e "  ${YELLOW}→ Conferma con la tua app 2FA${RESET}\n"

# Passa le opzioni direttamente: HTTPS + browser, niente domande interattive
gh auth login \
    --hostname github.com \
    --git-protocol https \
    --web

# ── Verifica e configurazione Git ───────────────────────────
if gh auth status &>/dev/null; then
    msg "Configurazione Git globale..."
    git config --global user.name  "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    gh auth setup-git

    echo ""
    echo -e "${BOLD}${GREEN}══════════════════════════════════════${RESET}"
    ok "Autenticazione completata!"
    echo -e "  ${BOLD}Utente :${RESET} $GIT_NAME"
    echo -e "  ${BOLD}Email  :${RESET} $GIT_EMAIL"
    echo -e "  ${BOLD}Protoc.:${RESET} HTTPS (token gestito da gh)"
    echo -e "${BOLD}${GREEN}══════════════════════════════════════${RESET}\n"
    ok "Push e pull HTTPS funzionano senza password."
else
    err "Autenticazione non completata. Riprova."
fi
