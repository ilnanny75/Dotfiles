# 🕵️ LEZIONE DI INFORMATICA: GOOGLE DORKING (OSINT)
# Scopo: Comprendere la visibilità dei dati online per la sicurezza informatica.

## 🛠 1. GLI OPERATORI FONDAMENTALI
# Questi sono i motori di base per filtrare i contenuti.

* site:       # Limita la ricerca a un sito o dominio (es. site:unimi.it)
* filetype:   # Cerca estensioni specifiche (es. filetype:pdf o filetype:sql)
* intitle:    # Cerca termini presenti nel titolo della pagina (tag <title>)
* inurl:      # Cerca termini presenti nell'indirizzo URL del sito
* intext:     # Cerca parole specifiche solo nel corpo del testo
* cache:      # Mostra l'ultima copia salvata da Google di una pagina
* AROUND(n)   # Trova due parole vicine tra loro di massimo "n" termini

---

## 📂 2. DIRECTORY LISTING (INDEX OF)
# I server mal configurati mostrano l'elenco dei file invece della pagina web.

* intitle:"index of" "parent directory"        # Trova la radice delle cartelle esposte
* intitle:"index of" /admin/                   # Cerca directory amministrative aperte
* intitle:"index of" /backup/                  # Cerca cartelle contenenti salvataggi dati
* intitle:"index of" /mail/                    # Cerca archivi di posta elettronica
* intitle:"index of" (mp3|mp4|mkv) "nome"      # Trova file multimediali su server aperti
* intitle:"index of" "password.txt"            # Uno dei dork più famosi per fughe di dati

---

## 🔐 3. CYBERSECURITY: FUGHE DI DATI E LOG
# Ricerca di file di sistema che non dovrebbero mai essere indicizzati.

* filetype:env "DB_PASSWORD"                   # Cerca file .env con password dei database
* filetype:log "access denied" "user"          # Analizza tentativi di accesso falliti nei log
* filetype:sql "INSERT INTO" "password"        # Trova dump di database con password in chiaro
* inurl:wp-config.php.bak                      # Cerca backup del file di configurazione WordPress
* ext:conf OR ext:ini "user" "pass"            # Cerca credenziali in file di configurazione
* ext:id_rsa intext:"-BEGIN RSA PRIVATE KEY-"  # Trova chiavi SSH private esposte

---

## 📡 4. IOT E DISPOSITIVI CONNESSI
# Molti hardware (telecamere, stampanti) hanno interfacce web indicizzate.

* intitle:"Live View / - AXIS"                 # Interfaccia standard telecamere IP Axis
* inurl:"view/view.shtml"                      # Altro percorso comune per webcam pubbliche
* intitle:"webcamXP 5"                         # Pannello di controllo software webcamXP
* intitle:"Network Configuration" "IP Address" # Dati di rete di router o stampanti
* "printer status" inurl:/hp/device/           # Stato e configurazione stampanti HP in rete
* intitle:"Toshiba Network Camera"             # Accesso a telecamere di sicurezza Toshiba

---

## 🚀 5. RICERCA DI DOCUMENTI RISERVATI
# Come trovare documenti sensibili dimenticati online.

* site:gov.it "riservato" filetype:pdf         # Documenti PDF riservati su siti governativi
* site:edu "confidential" filetype:doc         # Documenti confidenziali in ambito accademico
* "not for public release" filetype:pdf        # Documenti con clausola di non divulgazione
* site:it filetype:xls "email" "cellulare"     # Liste contatti esposte in formato Excel

---

## 📝 6. REGOLE D'ORO PER LA LEZIONE
# 1. Le virgolette ("") servono per la corrispondenza esatta della frase.
# 2. Il simbolo meno (-) serve a escludere siti (es: -site:amazon.it).
# 3. Il dorking è legale per scopi di analisi, ma l'accesso a sistemi privati non lo è.
# 4. Se Google invia un CAPTCHA, significa che le query sono troppo frequenti.
