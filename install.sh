#!/bin/bash

# Script d'installation pour extension GNOME
# Compatible toutes versions GNOME Shell

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
    echo "║    Installation Extension Luminosité Logicielle GNOME        ║"
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

# Vérifier les dépendances
check_dependencies() {
    print_info "Vérification des dépendances..."
    
    if ! command -v xrandr &> /dev/null; then
        print_warning "xrandr non installé, installation..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y x11-xserver-utils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xrandr
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm xorg-xrandr
        else
            print_error "Installez manuellement: xrandr"
            exit 1
        fi
    fi
    
    print_info "Dépendances installées ✓"
}

# Détection de GNOME
detect_gnome() {
    print_info "Détection de GNOME Shell..."
    
    if command -v gnome-shell &> /dev/null; then
        VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.\d+' | head -n1)
        if [ -n "$VERSION" ]; then
            print_info "GNOME Shell version: $VERSION"
        else
            print_warning "Version GNOME Shell non détectée, mais on continue..."
        fi
    else
        print_warning "GNOME Shell non détecté, mais on continue..."
    fi
}

# Installation
install_extension() {
    print_info "Installation de l'extension..."
    
    # Utiliser le répertoire de l'utilisateur actuel (pas root)
    if [ "$SUDO_USER" ]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        EXTENSION_DIR="$USER_HOME/.local/share/gnome-shell/extensions/software-brightness@custom-extension"
    else
        EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/software-brightness@custom-extension"
    fi
    
    # Créer le répertoire
    mkdir -p "$EXTENSION_DIR"
    
    # Copier les fichiers
    cp extension.js "$EXTENSION_DIR/"
    cp metadata.json "$EXTENSION_DIR/"
    cp stylesheet.css "$EXTENSION_DIR/"
    
    # Corriger les permissions si sudo
    if [ "$SUDO_USER" ]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$EXTENSION_DIR"
    fi
    
    print_info "Fichiers installés dans: $EXTENSION_DIR"
    
    # Créer la config
    if [ "$SUDO_USER" ]; then
        CONFIG_DIR="$USER_HOME/.config/brightness-control"
        sudo -u "$SUDO_USER" mkdir -p "$CONFIG_DIR"
        if [ ! -f "$CONFIG_DIR/current_brightness" ]; then
            echo "0.8" | sudo -u "$SUDO_USER" tee "$CONFIG_DIR/current_brightness" > /dev/null
        fi
    else
        CONFIG_DIR="$HOME/.config/brightness-control"
        mkdir -p "$CONFIG_DIR"
        if [ ! -f "$CONFIG_DIR/current_brightness" ]; then
            echo "0.8" > "$CONFIG_DIR/current_brightness"
        fi
    fi
    
    print_info "Configuration créée ✓"
}

# Activer l'extension
enable_extension() {
    print_info "Activation de l'extension..."
    
    if [ "$SUDO_USER" ]; then
        sudo -u "$SUDO_USER" gnome-extensions enable software-brightness@custom-extension 2>/dev/null || true
    else
        gnome-extensions enable software-brightness@custom-extension 2>/dev/null || true
    fi
    
    print_info "Extension activée ✓"
}

# Instructions finales
show_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║           Installation terminée avec succès! ✓                ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    print_info "Pour activer l'extension, vous DEVEZ:"
    echo ""
    echo "  1. Redémarrer GNOME Shell:"
    echo "     - Appuyez sur Alt+F2"
    echo "     - Tapez: r"
    echo "     - Appuyez sur Entrée"
    echo ""
    echo "  OU déconnectez-vous et reconnectez-vous"
    echo ""
    print_info "Après redémarrage, l'icône ☀️ apparaîtra en haut à droite"
    print_info "Cliquez dessus pour voir le curseur de luminosité"
    echo ""
    print_warning "Si l'icône n'apparaît pas, vérifiez les logs:"
    echo "  journalctl -f /usr/bin/gnome-shell | grep -i brightness"
    echo ""
}

# Main
main() {
    print_header
    check_dependencies
    detect_gnome
    install_extension
    enable_extension
    show_completion
}

main