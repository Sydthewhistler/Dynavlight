#!/bin/bash

# Désinstallation de l'extension

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo -e "${YELLOW}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║      Désinstallation Extension Luminosité                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Demander confirmation
read -p "Désinstaller l'extension ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    print_info "Annulé"
    exit 0
fi

# Désactiver
print_info "Désactivation..."
gnome-extensions disable software-brightness@custom-extension 2>/dev/null || true

# Restaurer luminosité
print_info "Restauration luminosité à 100%..."
if command -v xrandr &> /dev/null; then
    DISPLAY_OUTPUT=$(xrandr | grep " connected" | head -n1 | cut -d" " -f1)
    if [ -n "$DISPLAY_OUTPUT" ]; then
        xrandr --output "$DISPLAY_OUTPUT" --brightness 1.0 2>/dev/null || true
    fi
fi

# Supprimer
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/software-brightness@custom-extension"
if [ -d "$EXTENSION_DIR" ]; then
    rm -rf "$EXTENSION_DIR"
    print_info "Extension supprimée ✓"
fi

# Config
read -p "Supprimer la configuration ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    rm -rf "$HOME/.config/brightness-control"
    print_info "Configuration supprimée ✓"
fi

echo ""
print_info "Désinstallation terminée!"
print_warning "Redémarrez GNOME Shell (Alt+F2, puis 'r')"
echo ""