#!/bin/bash

# Dynavlight - Uninstall Script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║              Uninstalling Dynavlight                          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Ask for confirmation
read -p "Uninstall Dynavlight? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    print_info "Cancelled"
    exit 0
fi

# Disable
print_info "Disabling Dynavlight..."
gnome-extensions disable dynavlight@custom-extension 2>/dev/null || true

# Restore brightness
print_info "Restoring brightness to 100%..."
if command -v xrandr &> /dev/null; then
    DISPLAY_OUTPUT=$(xrandr | grep " connected" | head -n1 | cut -d" " -f1)
    if [ -n "$DISPLAY_OUTPUT" ]; then
        xrandr --output "$DISPLAY_OUTPUT" --brightness 1.0 2>/dev/null || true
    fi
fi

# Remove the extension
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/dynavlight@custom-extension"
if [ -d "$EXTENSION_DIR" ]; then
    rm -rf "$EXTENSION_DIR"
    print_info "Dynavlight removed ✓"
fi

# Config
read -p "Remove Dynavlight configuration? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    rm -rf "$HOME/.config/dynavlight"
    print_info "Configuration removed ✓"
fi

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║           Dynavlight uninstalled successfully! ✓              ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
print_warning "Restart GNOME Shell: killall -3 gnome-shell"
echo ""