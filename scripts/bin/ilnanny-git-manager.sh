#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Manager semplificato per il push dei dotfiles. 
# Automatizza l'aggiunta di file e l'invio al repository GitHub.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# Colori per un output leggibile
V="\e[32m"
C="\e[36m"
R="\e[31m"
RESET="\e[0m"

git_setup() {
    echo -e "${C}--- AGGIORNAMENTO REPOSITORY ---${RESET}"

    # Entra nella cartella dei dotfiles
    cd "$HOME/dotfiles" || { echo -e "${R}Errore: Cartella non trovata${RESET}"; exit 1; }

    # FIX PERMESSI: Evita che Git segnali ogni file come 'cambiato' a causa di Fedora/SELinux
    git config core.fileMode false

    # Aggiunge tutto, inclusi i nuovi font e icone
    git add .

    # Chiede il messaggio del commit
    echo -e "${V}Inserisci il messaggio del commit (es. 'Aggiunti font'):${RESET}"
    read -r messaggio

    if [ -z "$messaggio" ]; then
        messaggio="Aggiornamento automatico $(date +'%Y-%m-%d %H:%M')"
    fi

    git commit -m "$messaggio"

    echo -e "${C}Invio dei dati a GitHub...${RESET}"
    
    # Prova il push standard. Se fallisce per mancanza di upstream, lo imposta.
    if ! git push 2>/dev/null; then
        echo -e "${C}Configurazione upstream in corso per 'main'...${RESET}"
        git push --set-upstream origin main
    fi

    if [ $? -eq 0 ]; then
        echo -e "${V}✅ Operazione completata con successo!${RESET}"
    else
        echo -e "${R}❌ Errore durante il push. Controlla la connessione o i permessi.${RESET}"
    fi
}

# Esegue la funzione
git_setup
