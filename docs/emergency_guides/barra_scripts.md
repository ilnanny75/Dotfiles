## Barra di caricamento hollywod style :D


# Aggiungi questo, al .bashrc o agli script

hollywood_bar() {
    local duration=${1:-2}          # Default 2 secondi
    local task=${2:-"Caricamento"}  # Messaggio personale
    local color=${3:-"\033[0;36m"}  # Default Cyan
    local reset="\033[0m"
    local width=30                  # Larghezza barra
    
    echo -ne "${color}${task}...${reset}\n"
    for i in $(seq 1 $width); do
        # Calcolo velocità basato sulla durata totale
        sleep $(echo "scale=4; $duration/$width" | bc -l 2>/dev/null || echo 0.05)
        
        per=$((i * 100 / width))
        # Creazione barra: usa '=' per il pieno e '-' per il vuoto
        bar=$(printf "%-${width}s" "$(printf '#%.0s' $(seq 1 $i))")
        echo -ne "\r${color}[$bar] ${per}%${reset}"
    done
    echo -e "${color}\n[ COMPLETATO ]${reset}\n"
}

## Esempio d'uso

hollywood_bar 3 "Sincronizzazione Mirror" "\033[0;32m" # Barra verde, 3 secondi
sudo apt update -y

hollywood_bar 5 "Installazione Aggiornamenti" "\033[0;35m" # Barra viola, 5 secondi
sudo apt upgrade -y


## Crea una funzione in un file chiamato ~/.my_functions.sh.

## All'inizio di ogni tuo nuovo script, scrivi:
    source ~/.my_functions.sh

# Cosi se  decidi di cambiare il simbolo # con un X o i colori, basterà modificare un solo file .
