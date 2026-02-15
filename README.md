# Dynavlight - Dynamic Virtual Light

A GNOME Shell extension for software-based brightness control using xrandr.

![GNOME Version](https://img.shields.io/badge/GNOME-3.36--46+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

Dynavlight adds a brightness slider to your GNOME top panel. It's useful when hardware brightness controls don't work or when running in virtual machines.

**Features:**
- Brightness icon in top panel
- Slider control (10% - 100%)
- Real-time percentage display
- Auto-saves brightness level
- Auto-detects primary display
- Compatible with GNOME Shell 3.36-46+

---

## Requirements

- **GNOME Shell**: 3.36 or higher
- **xrandr**: Display configuration tool
- **X11 Session**: Not compatible with Wayland

Check your session type:
```bash
echo $XDG_SESSION_TYPE
# Should output: "x11"
```

If using Wayland, switch to X11:
1. Log out
2. Click gear icon at login
3. Select "GNOME on Xorg"
4. Log in

---

## Installation

### Standard Installation (No sudo)

```bash
# Clone repository
git clone https://github.com/Sydthewhistler/dynavlight.git
cd dynavlight

# Make installer executable
chmod +x install.sh

# Install
./install.sh

# Restart GNOME Shell (X11 only)
killall -3 gnome-shell
```

### With CLI Tool (Requires sudo)

```bash
# Install with CLI tool
sudo ./install.sh

# Restart GNOME Shell
killall -3 gnome-shell

# Verify
dynavlight version
```

Alternative restart methods:
```bash
gnome-shell --replace & disown
# OR log out/in
```

---

## Usage

### Graphical Interface

1. Click the brightness icon in the top panel
2. Move the slider to adjust brightness
3. Settings are saved automatically

### CLI Commands

If installed with sudo, use the `dynavlight` command:

```bash
# Show help
dynavlight help

# Enable/disable extension
dynavlight enable
dynavlight disable

# Show status
dynavlight status

# Restart GNOME Shell
dynavlight restart

# View logs
dynavlight logs

# Show version
dynavlight version
```

**Command aliases:**
- `dynavlight on` = `dynavlight enable`
- `dynavlight off` = `dynavlight disable`
- `dynavlight info` = `dynavlight status`

### GNOME Extensions Commands

```bash
# Enable
gnome-extensions enable dynavlight@custom-extension

# Disable
gnome-extensions disable dynavlight@custom-extension

# List all
gnome-extensions list

# Check if enabled
gnome-extensions list --enabled | grep dynavlight
```

---

## Configuration

**File locations:**
```
~/.local/share/gnome-shell/extensions/dynavlight@custom-extension/
├── extension.js
├── metadata.json
└── stylesheet.css

~/.config/dynavlight/
└── current_level    # Brightness value (0.1 - 1.0)
```

**View saved brightness:**
```bash
cat ~/.config/dynavlight/current_level
```

**Set manually:**
```bash
echo "0.5" > ~/.config/dynavlight/current_level  # 50%
```

---

## Troubleshooting

### Icon not visible

```bash
# Check installation
ls ~/.local/share/gnome-shell/extensions/dynavlight@custom-extension

# Check if enabled
gnome-extensions list --enabled | grep dynavlight

# Enable manually
gnome-extensions enable dynavlight@custom-extension

# Restart GNOME Shell (REQUIRED)
killall -3 gnome-shell
```

### Slider doesn't work

**Most common cause:** Running on Wayland or in a VM

**Check session:**
```bash
echo $XDG_SESSION_TYPE
```

**Test xrandr:**
```bash
# List displays
xrandr | grep connected

# Test brightness change
xrandr --output YOUR-DISPLAY --brightness 0.5
```

If this doesn't work, xrandr can't control your display (common in VMs).

### View logs

```bash
# With CLI tool
dynavlight logs

# Manual
journalctl -f /usr/bin/gnome-shell | grep -i dynavlight
```

---

## Known Limitations

**Virtual Machines:**
- Extension installs but slider has no effect
- xrandr cannot control virtual displays
- Affects VirtualBox, UTM, VMware, QEMU, etc.
- No workaround available

**Wayland:**
- xrandr requires X11
- Switch to "GNOME on Xorg" at login

**Multi-monitor:**
- Currently controls primary display only
- Multi-display support may come later

---

## Uninstallation

### Using script

```bash
./uninstall.sh
```

### Manual

```bash
# Disable
gnome-extensions disable dynavlight@custom-extension

# Remove files
rm -rf ~/.local/share/gnome-shell/extensions/dynavlight@custom-extension
rm -rf ~/.config/dynavlight

# Remove CLI tool (if installed)
sudo rm /usr/local/bin/dynavlight

# Restart
killall -3 gnome-shell
```

---

## Auto-start

Yes, Dynavlight starts automatically on boot if enabled. Brightness is restored from saved settings.

To disable auto-start:
```bash
gnome-extensions disable dynavlight@custom-extension
```

---

## FAQ

**Q: Does it work in VMs?**
A: Extension installs but won't control brightness. This is an xrandr limitation.

**Q: Why Wayland doesn't work?**
A: xrandr is X11-only. Switch to X11 session.

**Q: Where are settings saved?**
A: `~/.config/dynavlight/current_level`

**Q: How to reset to default?**
A: Delete config file and restart GNOME Shell. Default is 80%.

**Q: Multiple monitors?**
A: Currently controls primary display only.

---

## License

MIT License - See LICENSE file

---

## Support

- Issues: [GitHub Issues](https://github.com/Sydthewhistler/dynavlight/issues)

---

**Dynavlight** | Version 2.0 | GNOME Shell 3.36-46+