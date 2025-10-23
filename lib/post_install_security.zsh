#!/usr/bin/env zsh

set -e
set -u
set -o pipefail
IFS=$'\n\t'

# --- Source Utilities ---
if [ -f "$(dirname "$0")/utils.zsh" ]; then
  source "$(dirname "$0")/utils.zsh"
else
  source "$(dirname "$0")/utils.sh"
fi

print_header "Step 13: Security Tools Installation"

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    if ! command_exists brew; then
        die "Homebrew is required but not installed. Install from: https://brew.sh"
    fi

    if ! command_exists pipx; then
        die "pipx is required but not installed. Run: brew install pipx"
    fi

    # Check if pipx is in PATH
    if ! pipx list >/dev/null 2>&1; then
        warn "pipx may not be in PATH. Run: pipx ensurepath && exec \$SHELL -l"
        read "?Continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    info "Prerequisites check passed"
}

# Setup environment variables for building
setup_build_env() {
    info "Setting up build environment..."
    export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib ${LDFLAGS:-}"
    export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include ${CPPFLAGS:-}"

    # SQLCipher headers/libs for pysqlcipher3 (patator optional dep)
    if [ -d "/opt/homebrew/opt/sqlcipher" ]; then
        export PKG_CONFIG_PATH="/opt/homebrew/opt/sqlcipher/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
        export LDFLAGS="-L/opt/homebrew/opt/sqlcipher/lib ${LDFLAGS:-}"
        export CPPFLAGS="-I/opt/homebrew/opt/sqlcipher/include ${CPPFLAGS:-}"
    fi
    info "Build environment configured"
}

# Install Python tools via pipx
install_pipx_tools() {
    info "Installing Python security tools via pipx..."

    local PY312="/opt/homebrew/bin/python3.12"
    if [[ ! -f "$PY312" ]]; then
        PY312="$(command -v python3.12)"
    fi

    if [[ -z "$PY312" ]]; then
        warn "Python 3.12 not found. Install with: brew install python@3.12"
        return 1
    fi

    local tools=(
        "dirsearch"
        "wafw00f"
        "volatility3"
        "hashid"
        "patator"
        "checksec-py"
    )

    local git_tools=(
        "git+https://github.com/Tib3rius/AutoRecon.git|autorecon"
        "git+https://github.com/cddmp/enum4linux-ng.git|enum4linux-ng"
        "git+https://github.com/devanshbatham/ParamSpider.git|paramspider"
        "git+https://github.com/byt3bl33d3r/CrackMapExec.git|crackmapexec"
    )

    # Install PyPI packages (do not stop on failure)
    for tool in "${tools[@]}"; do
        if pipx list | grep -q "package $tool"; then
            warn "$tool already installed via pipx, skipping"
        else
            info "Installing $tool..."
            if pipx install --python "$PY312" "$tool"; then
                info "$tool installed successfully"
            else
                warn "Failed to install $tool"
            fi
        fi
    done

    # Install git packages (do not stop on failure)
    for entry in "${git_tools[@]}"; do
        local repo="${entry%%|*}"
        local tool="${entry##*|}"

        if pipx list | grep -q "package $tool" || pipx list | grep -q "$tool"; then
            warn "$tool already installed via pipx, skipping"
        else
            info "Installing $tool from git..."
            if pipx install --python "$PY312" "$repo"; then
                info "$tool installed successfully"
            else
                warn "Failed to install $tool"
            fi
        fi
    done
}

# Install Go tools
install_go_tools() {
    info "Installing Go security tools..."

    if ! command_exists go; then
        warn "Go is required but not installed. Run: brew install go"
        return 0
    fi

    # Add Go bin to PATH if not already there
    if [[ ! "$PATH" =~ "$HOME/go/bin" ]]; then
        export PATH="$HOME/go/bin:$PATH"
        info "Added \$HOME/go/bin to PATH for this session"
        info "Add this to your shell profile: export PATH=\"\$HOME/go/bin:\$PATH\""
    fi

    local go_tools=(
        "github.com/slimm609/checksec@latest|checksec"
    )

    for entry in "${go_tools[@]}"; do
        local repo="${entry%%|*}"
        local tool="${entry##*|}"

        if command_exists "$tool"; then
            warn "$tool already installed, skipping"
        else
            info "Installing $tool..."
            if go install "$repo"; then
                info "$tool installed successfully"
            else
                warn "Failed to install $tool"
            fi
        fi
    done
}

# Install Ruby gems
install_ruby_tools() {
    info "Installing Ruby security tools..."

    # Prefer Homebrew Ruby (>=3.0) when available
    if command_exists /opt/homebrew/opt/ruby/bin/ruby; then
        export PATH="/opt/homebrew/opt/ruby/bin:${PATH}"
    fi

    if ! command_exists gem; then
        warn "Ruby gems not available"
        return 0
    fi

    # Setup user gem directory
    local gem_dir="$(ruby -r rubygems -e 'puts Gem.user_dir' 2>/dev/null || echo "$HOME/.gem")"
    if [[ ! "$PATH" =~ "$gem_dir/bin" ]]; then
        export PATH="$gem_dir/bin:$PATH"
        info "Added gem user directory to PATH for this session"
        info "Add this to your shell profile: export PATH=\"\$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:\$PATH\""
    fi

    local ruby_tools=(
        "evil-winrm"
        "wpscan"
    )

    for tool in "${ruby_tools[@]}"; do
        if command_exists "$tool"; then
            warn "$tool already installed, skipping"
        else
            info "Installing $tool..."
            # Ensure gem installs to user dir to avoid permission issues
            if gem install --user-install "$tool"; then
                info "$tool installed successfully"
            else
                # Provide guidance if Ruby is too old
                if ruby -v 2>/dev/null | grep -q "ruby 2\."; then
                    warn "$tool failed; your system Ruby is too old. Install modern Ruby: brew install ruby, then re-run."
                else
                    warn "Failed to install $tool"
                fi
            fi
        fi
    done
}

# Install tools requiring special setup
install_special_tools() {
    info "Installing tools requiring special setup..."

    # Install dnsenum via tap (do not stop on failure)
    if command_exists dnsenum; then
        warn "dnsenum already installed, skipping"
    else
        info "Installing dnsenum via Kali tap..."
        if brew tap b-ramsey/homebrew-kali && brew install --HEAD dnsenum; then
            info "dnsenum installed successfully"
        else
            warn "Failed to install dnsenum"
        fi
    fi

    # Install dirb via tap (fallback if manual build fails)
    if command_exists dirb; then
        warn "dirb already installed, skipping"
    else
        info "Installing dirb via Kali tap..."
        if brew tap b-ramsey/homebrew-kali && brew install --HEAD dirb; then
            info "dirb installed successfully"
        else
            warn "Failed to install dirb via tap, you may need to build manually"
            info "Manual build instructions:"
            info "  mkdir -p ~/src && cd ~/src"
            info "  wget https://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz"
            info "  tar -xzf dirb222.tar.gz && chmod -R u+rwX dirb222 && cd dirb222"
            info "  ./configure && make && sudo make install"
        fi
    fi

    # Install nmap-parse-output manually
    local npo_path="$HOME/.local/tools/nmap-parse-output"
    local npo_bin="$HOME/.local/bin/nmap-parse-output"

    if [[ -x "$npo_bin" ]]; then
        warn "nmap-parse-output already installed, skipping"
    else
        info "Installing nmap-parse-output..."
        mkdir -p "$HOME/.local/tools" "$HOME/.local/bin"

        if [[ -d "$npo_path" ]]; then
            info "Updating existing nmap-parse-output repository..."
            (cd "$npo_path" && git pull)
        else
            if git clone https://github.com/ernw/nmap-parse-output.git "$npo_path"; then
                info "nmap-parse-output repository cloned"
            else
                warn "Failed to clone nmap-parse-output"
                return 0
            fi
        fi

        if ln -sf "$npo_path/nmap-parse-output" "$npo_bin"; then
            info "nmap-parse-output installed successfully"
            info "Make sure ~/.local/bin is in your PATH"
        else
            warn "Failed to create symlink for nmap-parse-output"
        fi
    fi
}

# Verify installations
verify_installations() {
    info "Verifying installations..."

    local tools=(
        "dnsenum:DNSENUM"
        "autorecon:AutoRecon"
        "enum4linux-ng.py:enum4linux-ng"
        "dirsearch:dirsearch"
        "dirb:DIRB"
        "paramspider:ParamSpider"
        "wafw00f:WAFW00F"
        "patator:patator"
        "cme:CrackMapExec"
        "evil-winrm:evil-winrm"
        "hashid:hashID"
        "nmap-parse-output:nmap-parse-output"
        "checksec:checksec (Go)"
        "checksec.py:checksec-py"
        "volatility3:Volatility3"
    )

    local installed=0
    local total=${#tools[@]}

    for entry in "${tools[@]}"; do
        local cmd="${entry%%:*}"
        local name="${entry##*:}"

        if command_exists "$cmd"; then
            info "✓ $name"
            ((installed++))
        else
            warn "✗ $name (command: $cmd)"
        fi
    done

    info "Installation summary: $installed/$total tools verified"

    if [[ $installed -eq $total ]]; then
        info "All tools installed successfully!"
    else
        warn "Some tools may need manual installation or PATH updates"
    fi
}

# Print post-install instructions
post_install_instructions() {
    info "Post-installation instructions:"
    echo
    echo "1. Add these to your shell profile (~/.zshrc):"
    echo "   export PATH=\"\$HOME/go/bin:\$PATH\""
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "   export PATH=\"\$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:\$PATH\""
    echo
    echo "2. Reload your shell: exec \$SHELL -l"
    echo
    echo "3. For Responder (if needed), consider using a Linux VM:"
    echo "   - Responder is unreliable on macOS due to network stack limitations"
    echo "   - Use UTM/Parallels with Kali Linux for full functionality"
    echo
    echo "4. Test your installation with:"
    echo "   nmap --version && nuclei -version && subfinder -version"
    echo
}

# Main installation function
main() {
    info "Starting security tools installation for M3 Mac..."
    echo

    check_prerequisites
    setup_build_env || warn "Build environment setup failed; continuing"

    info "Installing tools (this may take several minutes)..."
    install_pipx_tools || warn "pipx tools installation step failed; continuing"
    install_go_tools || warn "Go tools installation step failed; continuing"
    install_ruby_tools || warn "Ruby tools installation step failed; continuing"
    install_special_tools || warn "Special tools installation step failed; continuing"

    echo
    verify_installations
    echo
    post_install_instructions

    info "Security tools installation complete!"
}

# Run main function if script is executed directly (zsh-safe)
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi
