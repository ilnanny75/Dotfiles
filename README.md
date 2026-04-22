
# 🛠️ ilnanny Lab - Dotfiles
<p align="left">
  <a href="https://github.com/ilnanny75"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
  <a href="http://ilnanny.deviantart.com"><img src="https://img.shields.io/badge/DeviantArt-181717?style=for-the-badge&logo=deviantart&logoColor=white" /></a>
  <a href="https://www.gnome-look.org/u/ilnanny75/products"><img src="https://img.shields.io/badge/Gnome--Look-181717?style=for-the-badge&logo=gnome&logoColor=white" /></a>
  <a href="https://openclipart.org/artist/ilnanny"><img src="https://img.shields.io/badge/OpenClipart-181717?style=for-the-badge&logo=inkscape&logoColor=white" /></a>
</p>

---

**Laboratorio personale di script e configurazioni Linux (Debian, Void, Arch).**

---

### 🚀 Setup Istantaneo
Se hai appena scaricato i dotfiles o sei su un nuovo sistema, usa il Master Manager per collegare tutto in modo automatico:

```bash
git clone https://github.com/ilnanny75/dotfiles.git
cd ~/dotfiles && chmod +x ilnanny-OS-manager.sh && ./ilnanny-OS-manager.sh
```
---

### 📂 Struttura Modulare
Il laboratorio è¨ intelligente e riconosce automaticamente l'OS:

* **bash/etc_bash/bashrc.d**: Moduli Bash Universali (env ,core e prompt).
* **Debian / Void / Arch / Fedora**: Configurazioni caricate in base alla distro.
* **scripts/bin**: Il cuore degli script (Icone, Git Manager, Fix Hardware).
* **config**: Sincronizzazione automatica per Openbox, Thunar, XFCE ,ecc


---

### 🛠️ Manutenzione
Per ricaricare le modifiche agli alias senza reavviare il terminale:

```bash
source ~/.bashrc
```
---

<p align="left">
  <i>"Il codice è¨ come il caffè¨: deve essere pulito, forte e senza errori."</i>
</p>
