```
  _|_|_|  _|_|_|    _|_|    _|_|_|      _|_|    
_|          _|    _|    _|  _|    _|  _|    _|  
_|          _|    _|    _|  _|_|_|    _|_|_|_|  
_|          _|    _|    _|  _|    _|  _|    _|  
  _|_|_|  _|_|_|    _|_|    _|    _|  _|    _|
```

# 🌐 Ciora

Ciora is a **Bash-based recon automation tool** built for bug bounty hunters and pentesters.  
It downloads the **HackerOne program scope** (public or private with session cookie), extracts web assets & wildcards, and optionally performs **subdomain enumeration** using multiple tools.

---

## ✨ Features
- 🔑 Supports **public & private HackerOne programs** (cookie auth for private).  
- 📂 Automatically extracts:  
  - Web assets  
  - Wildcards  
  - Cleaned wildcard domains  
- 🔎 Subdomain enumeration with:  
  - Amass  
  - Sublist3r  
  - Assetfinder  
  - Subfinder  
  - ShuffleDNS  
- 🧹 **Future improvements:** add tools to clean more subdomains, URLs, and perform deeper scope analysis.  
- 📑 Merges results into one file (`all_subdomains.txt`).  
- ✅ Pretty banner + clean output.

---

## ⚙️ Installation

Clone the repo and install dependencies:

```bash
git clone https://github.com/yourusername/ciora.git
cd ciora
chmod +x ciora.sh install.sh
./install.sh
```

The installer will:  
- Install the latest **Go**  
- Add `~/go/bin` to your PATH  
- Install all required tools (Amass, Subfinder, Assetfinder, Sublist3r, ShuffleDNS, Nuclei, httprobe, etc.)

---

## 🚀 Usage

Run the tool:

```bash
./ciora.sh
```

### Example (public program):

```
====== Enter the HackerOne program name: ======
example
====== Enter __Host-session cookie (leave blank for public programs): ======
[press Enter]
```

### Example (private program):

```
====== Enter the HackerOne program name: ======
private-program
====== Enter __Host-session cookie (leave blank for public programs): ======
<your_cookie_here>
```

---

## 📂 Output Structure

After running, you’ll get:

```
example.csv                  # Raw HackerOne scope
example-webscope.txt          # Regular web assets
example-wildcards.txt         # Wildcards
example-wildscope.txt         # Wildcards cleaned (no *)

subdomains/                   # Subdomain results per tool
all_subdomains.txt            # Final merged subdomain list
```

---

## ⚠️ Disclaimer

This tool is for **educational and authorized security testing only**.  
Do **not** use against targets without explicit permission.  
You are responsible for your actions.
```
# ciora
