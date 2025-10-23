# Security Tools Installation

This dotfiles setup includes comprehensive security and penetration testing tools installation for M3 Macs.

## 🚀 Quick Start

### Option 1: Install Everything (Recommended)
```bash
cd ~/dotfiles
INSTALL_SECURITY_TOOLS=1 ./install.zsh
```

### Option 2: Install Just Security Tools
```bash
cd ~/dotfiles
# First install base system
./install.zsh
# Then add security tools
INSTALL_SECURITY_TOOLS=1 zsh lib/post_install_security.zsh
```

## 🛠️ What Gets Installed

### Via Homebrew
- **Network Discovery**: `nmap`, `masscan`, `rustscan`, `amass`, `subfinder`, `nuclei`, `fierce`
- **Web Testing**: `gobuster`, `feroxbuster`, `ffuf`, `httpx`, `katana`, `nikto`, `sqlmap`, `wpscan`, `arjun`, `dalfox`
- **Password Attacks**: `hydra`, `john`, `hashcat`, `medusa`, `ophcrack`
- **Binary Analysis**: `gdb`, `radare2`, `binwalk`, `foremost`, `exiftool`, `steghide`
- **GUI Tools**: `ghidra` (reverse engineering suite)
- **Dependencies**: `mysql-client`, `samba`, `libxslt`, `pkg-config`, `autoconf`, etc.

### Via pipx (Python)
- **Reconnaissance**: `autorecon`, `enum4linux-ng`, `dirsearch`, `paramspider`
- **Web Security**: `wafw00f`, `volatility3`
- **Password Tools**: `patator`, `hashid` (modern hash identifier)
- **Binary Tools**: `checksec-py` (Python version with Mach-O support)
- **Exploitation**: `crackmapexec` (archived but functional)

### Via Go
- **Binary Security**: `checksec` (official Go version)

### Via Ruby gem
- **Windows Exploitation**: `evil-winrm`

### Via Special Installation
- **DNS Tools**: `dnsenum` (via Kali tap)
- **Directory Brute Force**: `dirb` (via Kali tap)
- **Nmap Helper**: `nmap-parse-output` (manual git install)

## 🔧 Post-Installation

After installation, add these to your shell profile (`~/.zshrc`):
```bash
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
```

Then reload your shell:
```bash
exec $SHELL -l
```

## ✅ Verification

Test your installation:
```bash
# Core tools
nmap --version
nuclei -version
subfinder -version

# Python tools
autorecon --version
enum4linux-ng.py --version
dirsearch --help

# Go tools
checksec --help

# Ruby tools
evil-winrm --version
```

## ⚠️ macOS Limitations

Some tools have limitations on macOS:

- **Responder**: Unreliable due to macOS network stack limitations. Use Linux VM for full functionality.
- **CrackMapExec**: Archived project but still functional via pipx install.
- **Network Tools**: Some advanced network manipulation tools work better in Linux containers.

## 🔒 Legal Notice

These tools are for authorized security testing only. Always ensure you have permission before testing any systems. Use responsibly and ethically.

## 🆘 Troubleshooting

### Common Issues

1. **pipx not in PATH**: Run `pipx ensurepath && exec $SHELL -l`
2. **Python 3.12 missing**: Install with `brew install python@3.12`
3. **Go tools not found**: Ensure `$HOME/go/bin` is in PATH
4. **Ruby gems not found**: Ensure gem user directory is in PATH

### Manual Fallbacks

If automated installation fails, you can install individual tools:

```bash
# Python tools
pipx install --python "$(command -v python3.12)" dirsearch
pipx install --python "$(command -v python3.12)" git+https://github.com/Tib3rius/AutoRecon.git

# Go tools
go install github.com/slimm609/checksec@latest

# Ruby tools
gem install --user-install evil-winrm

# Tap-based tools
brew tap b-ramsey/homebrew-kali
brew install --HEAD dnsenum
brew install --HEAD dirb
```

## 🎯 Ready to Hack Ethically!

Your M3 Mac is now equipped with a comprehensive penetration testing toolkit. Remember to use these tools responsibly and only on systems you own or have explicit permission to test.

Happy ethical hacking! 🚀
