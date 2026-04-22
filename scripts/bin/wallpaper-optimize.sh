#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Wallpaper Optimizer.
# Ottimizza i PNG e JPG riducendo il peso senza perdere qualità
# 
#  Autore: ilnanny 2026
#  Mail:   ilnannyhack@gmail.com
#  GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

TARGET_DIR="${1:-.}"
cd "$TARGET_DIR" || { echo "Errore: Directory non trovata"; exit 1; }

echo "🚀 Operazione avviata in: $(pwd)"

# Variabili per il calcolo del risparmio
SIZE_BEFORE=$(du -sb . | cut -f1)
COUNT=0

# Ciclo unico per PNG, JPG e JPEG (case-insensitive grazie a nullglob e nocaseglob se volessi, 
# ma qui usiamo un approccio standard compatibile)
for f in *.{png,jpg,jpeg,PNG,JPG,JPEG}; do
    # Verifica se il file esiste (evita errori se non ci sono match)
    [ -e "$f" ] || continue
    
    echo "⚙️  Ottimizzazione in corso: $f"
    
    # Salviamo la dimensione originale del singolo file per un controllo qualità/peso
    ORIG_FILE_SIZE=$(stat -c%s "$f")
    
    # Eseguiamo l'ottimizzazione su un file temporaneo
    # Per JPG usiamo -sampling-factor 4:2:0 che è standard per il web/desktop
    magick "$f" -strip -quality 85 "${f%.*}_temp.${f##*.}"
    
    NEW_FILE_SIZE=$(stat -c%s "${f%.*}_temp.${f##*.}")

    # Logica di controllo: se il file ottimizzato è più grande o identico, 
    # scartiamo la modifica per mantenere l'originale
    if [ "$NEW_FILE_SIZE" -lt "$ORIG_FILE_SIZE" ]; then
        mv "${f%.*}_temp.${f##*.}" "$f"
        ((COUNT++))
    else
        rm "${f%.*}_temp.${f##*.}"
        echo "   ↪ Saltato (nessun guadagno di peso trovato)"
    fi
done

# Calcolo finale dello spazio risparmiato
SIZE_AFTER=$(du -sb . | cut -f1)
SAVED_BYTES=$((SIZE_BEFORE - SIZE_AFTER))
SAVED_MB=$(echo "scale=2; $SAVED_BYTES / 1048576" | bc)

echo "---"
echo "✅ Operazione completata!"
echo "🖼️  File ottimizzati: $COUNT"
echo "📉 Spazio totale recuperato: $SAVED_MB MB"
echo "I tuoi file sono pronti e leggeri per XFCE."
