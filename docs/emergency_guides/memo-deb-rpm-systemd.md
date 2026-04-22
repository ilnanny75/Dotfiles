# 🐧 Guida Rapida alla Sopravvivenza: RPM vs DEB

Questa guida riassume i comandi fondamentali per gestire le distro binarie (Fedora/Debian)
senza rimpiangere troppo la compilazione manuale.

---

## 📦 1. Gestione Pacchetti (Standard)

| Operazione | **DNF** (Fedora/RedHat) | **APT** (Debian/Ubuntu) |
| :--- | :--- | :--- |
| **Installare** | `sudo dnf install <pkg>` | `sudo apt install <pkg>` |
| **Rimuovere** | `sudo dnf remove <pkg>` | `sudo apt remove <pkg>` |
| **Cercare** | `dnf search <parola>` | `apt search <parola>` |
| **Aggiornare Repo** | `dnf check-update` | `sudo apt update` |
| **Aggiornare Sistema** | `sudo dnf upgrade` | `sudo apt upgrade` |
| **Installare file locale** | `sudo dnf install ./file.rpm` | `sudo apt install ./file.deb` |
| **Info pacchetto** | `dnf info <pkg>` | `apt show <pkg>` |
| **Pulizia Cache** | `sudo dnf clean all` | `sudo apt autoremove` |

---

## 🛠 2. Modalità "Forzata" (Senza Dipendenze)

> ⚠️ **ATTENZIONE:** Usare solo in emergenza. Può rendere il sistema instabile.

### Su Fedora (RPM)
* **Installa ignorando dipendenze:**
  `sudo rpm -ivh --nodeps pacchetto.rpm`
* **Rimuovi ignorando dipendenze:**
  `sudo rpm -e --nodeps nome_pacchetto`

### Su Debian (DEB)
* **Installa ignorando dipendenze:**
  `sudo dpkg -i --force-depends pacchetto.deb`
* **Rimuovi ignorando dipendenze:**
  `sudo dpkg -r --force-depends nome_pacchetto`
* **Riparare dipendenze rotte:**
  `sudo apt install -f`

---

## ⚙️ 3. Gestione Servizi (Systemd)

Al posto dei vecchi script in `/etc/init.d/` o `rc-update` di Gentoo, ora si usa `systemctl`.

* **Avviare un servizio:** `sudo systemctl start <servizio>`
* **Fermare un servizio:** `sudo systemctl stop <servizio>`
* **Abilitare al boot:** `sudo systemctl enable <servizio>`
* **Disabilitare al boot:** `sudo systemctl disable <servizio>`
* **Controllare lo stato:** `systemctl status <servizio>`
* **Vedere i log (fondamentale):** `journalctl -u <servizio> -f`

---

## 🔍 4. Utility Utili
* **Trovare a quale pacchetto appartiene un file:**
  * Fedora: `dnf provides /percorso/file`
  * Debian: `dpkg -S /percorso/file` (richiede `apt-file` per file non installati)
* **Elenco pacchetti installati:**
  * Fedora: `dnf list installed`
  * Debian: `dpkg -l`