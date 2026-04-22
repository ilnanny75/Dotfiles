#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Coltellino svizzero Git. Menu avanzato per commit, push, 
# pull intelligente, diagnostica e fix da SSH a HTTPS.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -uo pipefail

# ── Colori ──────────────────────────────────────────────────────
VERDE="\e[32m"; ROSSO="\e[31m"; GIALLO="\e[33m"
CIANO="\e[36m"; GRASSETTO="\e[1m"; RESET="\e[0m"
BLU="\e[34m"; MAGENTA="\e[35m"

# ── Messaggistica ───────────────────────────────────────────────
# Definisce le funzioni di output per la formattazione del testo
info()    { echo -e "${CIANO}  ℹ  $*${RESET}"; }
ok()      { echo -e "${VERDE}  ✔  $*${RESET}"; }
warn()    { echo -e "${GIALLO}  ⚠  $*${RESET}"; }
errore()  { echo -e "${ROSSO}  ✘  $*${RESET}"; }
titolo()  { echo -e "\n${GRASSETTO}${CIANO}  ══  $* ══${RESET}\n"; }
passo()   { echo -e "${BLU}  →  $*${RESET}"; }
linea()   { echo -e "${CIANO}  ────────────────────────────────────────${RESET}"; }
pausa()   { echo ""; read -rp "  Premi [INVIO] per continuare..." _; }

# ── Branch corrente (helper) ─────────────────────────────────────
# Recupera il nome del branch attivo o restituisce "main" come default
branch_corrente() { git branch --show-current 2>/dev/null || echo "main"; }

# ── Controllo: siamo in un repo git? ────────────────────────────
# Verifica se la directory corrente fa parte di un repository Git
controlla_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        errore "Questa cartella NON è un repository git."
        errore "Spostati nella cartella giusta prima di usare questo tool."
        exit 1
    fi
}

# ════════════════════════════════════════════════════════════════
#  OTTIMIZZAZIONE PESO — Analisi e pulizia della cartella .git
# ════════════════════════════════════════════════════════════════
ottimizzazione_peso() {
    titolo "OTTIMIZZAZIONE & PULIZIA PESANTE"
    
    # Verifica l'esistenza fisica della cartella .git
    if [[ ! -d ".git" ]]; then
        errore "Cartella .git non trovata! Il repository potrebbe essere corrotto."
        pausa; return
    fi

    # Controlla la disponibilità del comando 'du' per il calcolo del volume
    local peso_git="Sconosciuto"
    if ! command -v du &>/dev/null; then
        warn "Comando 'du' non trovato nel sistema. Peso non calcolabile."
    else
        peso_git=$(du -sh .git 2>/dev/null | cut -f1)
    fi
    
    info "Volume attuale della cartella .git: ${GRASSETTO}${peso_git}${RESET}"
    linea

    # Conta i file modificati per prevenire perdite accidentali di dati
    local modificati
    modificati=$(git status --porcelain 2>/dev/null | wc -l)
    
    if [[ "$modificati" -gt 0 ]]; then
        warn "ATTENZIONE: Risultano $modificati file non salvati."
        warn "Il repository deve essere pulito per procedere con il reset della storia."
        info "Si consiglia di usare l'opzione 2 (Push) o 4 (Pull) prima di continuare."
        echo ""
    fi

    echo "  Seleziona il tipo di intervento:"
    echo "  1) Soft: Compressione e rimozione oggetti orfani (git gc)"
    echo "  2) Hard: Reset totale della storia (mantiene i file, svuota .git)"
    echo "  3) Annulla"
    echo ""
    read -rp "  Scelta: " opt_clean

    case $opt_clean in
        1)
            passo "Esegue la compressione aggressiva..."
            git gc --prune=now --aggressive
            ok "Operazione conclusa."
            [[ "$peso_git" != "Sconosciuto" ]] && info "Nuovo volume: $(du -sh .git | cut -f1)"
            ;;
        2)
            if [[ "$modificati" -gt 0 ]]; then
                errore "Operazione bloccata: sono presenti modifiche non committate."
            else
                warn "Questa azione cancella definitivamente tutta la cronologia passata."
                read -rp "  Digitare 'RESET' per confermare l'azione: " confirm_reset
                if [[ "$confirm_reset" == "RESET" ]]; then
                    local remote_url
                    remote_url=$(git remote get-url origin)
                    local branch
                    branch=$(branch_corrente)

                    passo "Ricostruisce il repository da zero..."
                    rm -rf .git
                    git init &>/dev/null
                    git checkout -b "$branch" &>/dev/null
                    git add .
                    git commit -m "Ottimizzazione: reset cronologia ($(date +'%Y-%m-%d'))"
                    git remote add origin "$remote_url"
                    
                    ok "Repository rigenerato con successo!"
                    [[ "$peso_git" != "Sconosciuto" ]] && info "Peso finale .git: $(du -sh .git | cut -f1)"
                    warn "È necessario eseguire un Force Push (opzione 5) per aggiornare GitHub."
                else
                    info "Azione annullata dall'utente."
                fi
            fi
            ;;
        *)
            info "Uscita dalla sezione ottimizzazione."
            ;;
    esac
    pausa
}

# ════════════════════════════════════════════════════════════════
#  DIAGNOSTICA — Verifica l'integrità dell'ambiente di lavoro
# ════════════════════════════════════════════════════════════════
diagnostica() {
    titolo "DIAGNOSTICA COMPLETA"
    local problemi=0

    # Verifica la presenza del binario git
    passo "Controllo git..."
    if command -v git &>/dev/null; then
        ok "git trovato: $(git --version)"
    else
        errore "git NON trovato nel PATH."
        ((problemi++))
    fi

    # Controlla lo stato della GitHub CLI
    passo "Controllo github-cli (gh)..."
    if command -v gh &>/dev/null; then
        ok "gh trovato."
        if gh auth status &>/dev/null; then
            ok "Sessione GitHub attiva."
        else
            warn "gh presente ma non autenticato."
            ((problemi++))
        fi
    else
        warn "github-cli non installato."
    fi

    # Verifica le configurazioni globali dell'utente
    passo "Controllo identità git..."
    local nome email
    nome=$(git config --global user.name 2>/dev/null)
    email=$(git config --global user.email 2>/dev/null)
    if [[ -n "$nome" && -n "$email" ]]; then
        ok "Identità configurata correttamente."
    else
        warn "Identità mancante."
        ((problemi++))
    fi

    linea
    if [[ $problemi -eq 0 ]]; then
        ok "Ambiente di lavoro ottimale."
    else
        warn "Rilevate anomalie configurative."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  FIX SSH → HTTPS — Correzione remoti per autenticazione gh
# ════════════════════════════════════════════════════════════════
fix_ssh_https() {
    titolo "FIX: SSH → HTTPS"
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || true)

    if [[ -z "$remote_url" ]]; then
        errore "Nessun remote origin rilevato."
        pausa; return
    fi

    # Converte l'URL da formato SSH a HTTPS se necessario
    if [[ "$remote_url" == git@github.com:* ]]; then
        local nuovo_url
        nuovo_url=$(echo "$remote_url" | sed 's|git@github.com:|https://github.com/|')
        passo "Conversione in: $nuovo_url"
        read -rp "  Applicare modifica? (s/N): " ok_risposta
        if [[ "$ok_risposta" =~ ^[Ss]$ ]]; then
            git remote set-url origin "$nuovo_url"
            ok "Remote aggiornato."
        fi
    else
        ok "Il remote non richiede conversioni SSH."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  STATO REPO — Panoramica della situazione locale e remota
# ════════════════════════════════════════════════════════════════
stato_repo() {
    titolo "STATO REPOSITORY"
    info "Directory: $(pwd)"
    info "Branch:    $(branch_corrente)"
    linea
    git status -s
    linea
    # Calcola il divario tra i commit locali e quelli sul server
    local ahead behind
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "?")
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "?")
    info "Commit da inviare: $ahead | Commit da scaricare: $behind"
    pausa
}

# ════════════════════════════════════════════════════════════════
#  SUPER PUSH — Automazione dell'invio modifiche
# ════════════════════════════════════════════════════════════════
super_push() {
    titolo "COMMIT & PUSH"
    local branch
    branch=$(branch_corrente)

    git add .
    if git diff --cached --quiet; then
        warn "Nessun cambiamento rilevato per il commit."
    else
        read -rp "  Messaggio (INVIO per auto): " msg
        [[ -z "$msg" ]] && msg="Update $(date +'%H:%M')"
        git commit -m "$msg"
        ok "Commit eseguito."
    fi

    passo "Invio dei dati a GitHub..."
    if git push origin "$branch"; then
        ok "Push terminato con successo."
    else
        errore "Errore durante il push."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  PULL INTELLIGENTE — Sincronizzazione con gestione conflitti
# ════════════════════════════════════════════════════════════════
pull_intelligente() {
    titolo "PULL & SINCRONIZZAZIONE"
    local branch
    branch=$(branch_corrente)

    passo "Tentativo di sincronizzazione (rebase)..."
    if git pull origin "$branch" --rebase 2>/dev/null; then
        ok "Sincronizzazione completata."
    else
        warn "Conflitti rilevati."
        # Gestione manuale delle divergenze
        info "Risoluzione consigliata: usare merge manuale o rebase abort."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  FORCE PUSH — Sovrascrittura forzata del ramo remoto
# ════════════════════════════════════════════════════════════════
force_push() {
    titolo "FORCE PUSH ⚠"
    warn "Azione distruttiva per il repository remoto."
    read -rp "  Confermare con 'forza': " confirm
    if [[ "$confirm" == "forza" ]]; then
        git push origin "$(branch_corrente)" --force
        ok "Repository remoto aggiornato forzatamente."
    else
        info "Azione annullata."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  MANUTENZIONE — Log e Cache
# ════════════════════════════════════════════════════════════════
mostra_log() {
    titolo "LOG RECENTE"
    git log -n 10 --oneline --graph --decorate
    pausa
}

pulizia_cache() {
    titolo "PULIZIA CACHE"
    # Rimuove l'indice mantenendo i file fisici per ricalcolare il .gitignore
    git rm -r --cached . &>/dev/null
    git add .
    ok "Cache Git resettata."
    pausa
}

undo_ultimo_commit() {
    titolo "ANNULLA COMMIT"
    # Ripristina lo stato precedente al commit mantenendo le modifiche nei file
    git reset --soft HEAD~1
    ok "Ultimo commit rimosso (modifiche preservate)."
    pausa
}

# ════════════════════════════════════════════════════════════════
#  MENU PRINCIPALE — Interfaccia utente
# ════════════════════════════════════════════════════════════════
main_menu() {
    controlla_repo
    while true; do
        clear
        echo -e "\n${GRASSETTO}${CIANO}  🛠  GIT MULTITOOL — ilnanny75${RESET}"
        echo -e "  ${BLU}Dir:    ${GIALLO}$(pwd)${RESET}"
        echo -e "  ${BLU}Branch: ${VERDE}$(branch_corrente)${RESET}"
        linea
        echo "   1)  📋  Stato repo"
        echo "   2)  🚀  Commit & Push"
        echo "   3)  📜  Log recenti"
        echo "   4)  ⬇   Pull intelligente"
        echo "   5)  💪  Force Push"
        echo "   6)  🔍  Diagnostica"
        echo "   7)  ↩   Annulla commit"
        echo "   8)  🔧  Fix SSH → HTTPS"
        echo "   9)  🧹  Pulizia cache"
        echo "   10) ⚖   Ottimizzazione peso (Hard Reset)"
        echo "   0)  🚪  Esci"
        echo ""
        read -rp "  Scegli un'opzione: " SCELTA

        case "$SCELTA" in
            1) stato_repo ;;
            2) super_push ;;
            3) mostra_log ;;
            4) pull_intelligente ;;
            5) force_push ;;
            6) diagnostica ;;
            7) undo_ultimo_commit ;;
            8) fix_ssh_https ;;
            9) pulizia_cache ;;
            10) ottimizzazione_peso ;;
            0) ok "Uscita dal programma."; exit 0 ;;
            *) errore "Scelta non valida."; sleep 1 ;;
        esac
    done
}

# Avvio del programma
main_menu
