#!/bin/bash

# Dynavlight - Dynamic Virtual Light
# Installation script for GNOME Shell

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║                    🌟 DYNAVLIGHT 🌟                           ║"
    echo "║              Dynamic Virtual Light Control                    ║"
    echo "║                                                               ║"
    echo "║             Compatible GNOME Shell 3.36 - 46+                ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v xrandr &> /dev/null; then
        print_warning "xrandr not installed, installing..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y x11-xserver-utils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xrandr
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm xorg-xrandr
        else
            print_error "Please install manually: xrandr"
            exit 1
        fi
    fi

    print_info "Dependencies installed ✓"
}

# Detect GNOME
detect_gnome() {
    print_info "Detecting GNOME Shell..."
    
    if command -v gnome-shell &> /dev/null; then
        VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.\d+' | head -n1)
        if [ -n "$VERSION" ]; then
            print_info "GNOME Shell version: $VERSION"
        else
            print_warning "GNOME Shell version not detected"
        fi
    else
        print_warning "GNOME Shell not detected"
    fi
}

# Installation
install_dynavlight() {
    print_info "Installation of Dynavlight..."

    # use current user's directory
    if [ "$SUDO_USER" ]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        EXTENSION_DIR="$USER_HOME/.local/share/gnome-shell/extensions/dynavlight@custom-extension"
    else
        EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/dynavlight@custom-extension"
    fi

    # Create the directory
    mkdir -p "$EXTENSION_DIR"

    # Copy files
    cp extension.js "$EXTENSION_DIR/"
    cp metadata.json "$EXTENSION_DIR/"
    cp stylesheet.css "$EXTENSION_DIR/"

    # Fix permissions
    if [ "$SUDO_USER" ]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$EXTENSION_DIR"
    fi

    print_info "Files installed in: $EXTENSION_DIR"

    # Create configuration
    if [ "$SUDO_USER" ]; then
        CONFIG_DIR="$USER_HOME/.config/dynavlight"
        sudo -u "$SUDO_USER" mkdir -p "$CONFIG_DIR"
        if [ ! -f "$CONFIG_DIR/current_level" ]; then
            echo "0.8" | sudo -u "$SUDO_USER" tee "$CONFIG_DIR/current_level" > /dev/null
        fi
    else
        CONFIG_DIR="$HOME/.config/dynavlight"
        mkdir -p "$CONFIG_DIR"
        if [ ! -f "$CONFIG_DIR/current_level" ]; then
            echo "0.8" > "$CONFIG_DIR/current_level"
        fi
    fi
    
    print_info "Configuration created ✓"
}

# Enable the extension
enable_dynavlight() {
    print_info "Enabling Dynavlight..."
    
    if [ "$SUDO_USER" ]; then
        sudo -u "$SUDO_USER" gnome-extensions enable dynavlight@custom-extension 2>/dev/null || true
    else
        gnome-extensions enable dynavlight@custom-extension 2>/dev/null || true
    fi

    print_info "Dynavlight enabled ✓"
}

# Install the dynavlight command
install_command() {
    print_info "Installing 'dynavlight' command..."
    
    if [ -f "dynavlight" ]; then
        sudo cp dynavlight /usr/local/bin/dynavlight
        sudo chmod +x /usr/local/bin/dynavlight
        print_info "'dynavlight' command installed ✓"
    else
        print_warning "'dynavlight' file not found, command not installed"
    fi
}

# Final instructions
show_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║              ✨ Installation successful! ✨                   ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    print_info "To enable Dynavlight, you MUST:"
    echo ""
    echo "  ${YELLOW}Restart GNOME Shell:${NC}"
    echo "  ${BLUE}┌─────────────────────────────────────────┐${NC}"
    echo "  ${BLUE}│${NC} killall -3 gnome-shell               ${BLUE}│${NC}"
    echo "  ${BLUE}│${NC} OR                                   ${BLUE}│${NC}"
    echo "  ${BLUE}│${NC} gnome-shell --replace & disown       ${BLUE}│${NC}"
    echo "  ${BLUE}└─────────────────────────────────────────┘${NC}"
    echo ""
    print_info "After restarting, the ☀️ Dynavlight icon will appear in the top right"
    echo ""
    print_info "Dynavlight commands:"
    echo "  dynavlight enable    - Enable"
    echo "  dynavlight disable   - Disable"
    echo "  dynavlight status    - View status"
    echo ""
    print_warning "Note: On VM, xrandr may not work"
    print_warning "The icon will appear but the cursor may not have an effect"
    echo ""
}

# Main
main() {
    print_header
    check_dependencies
    detect_gnome
    install_dynavlight
    enable_dynavlight
    install_command
    show_completion
}

main