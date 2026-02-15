/* extension.js
 *
 * Dynavlight - Dynamic Virtual Light
 * GNOME Shell extension for software brightness control
 * Compatible GNOME Shell 3.36 - 46+
 */

const { GObject, St, Clutter, Gio, GLib } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Slider = imports.ui.slider;

// Dynavlight indicator class
const DynavlightIndicator = GObject.registerClass(
class DynavlightIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Dynavlight');

    // Icon in the system panel
        this._icon = new St.Icon({
            icon_name: 'display-brightness-symbolic',
            style_class: 'system-status-icon',
        });
        this.add_child(this._icon);

    // Detect display
        this._detectDisplay();
        
    // Load saved brightness
        this._loadDynavlight();

    // Build the menu
        this._buildMenu();
        
        log('Dynavlight: Initialisé avec succès');
    }

    _detectDisplay() {
        try {
            let [ok, stdout, stderr, status] = GLib.spawn_command_line_sync('xrandr');
            if (ok) {
                let output = imports.byteArray.toString(stdout);
                let lines = output.split('\n');
                
                // Search for the primary display
                for (let line of lines) {
                    if (line.includes('connected primary')) {
                        this._display = line.split(' ')[0];
                        log(`Dynavlight: Écran principal détecté: ${this._display}`);
                        return;
                    }
                }
                
                // Otherwise, take the first connected
                for (let line of lines) {
                    if (line.includes('connected') && !line.includes('disconnected')) {
                        this._display = line.split(' ')[0];
                        log(`Dynavlight: Écran détecté: ${this._display}`);
                        return;
                    }
                }
            }
        } catch (e) {
            log(`Dynavlight: Erreur détection: ${e}`);
        }

        this._display = 'Virtual-1';
        log(`Dynavlight: Écran par défaut: ${this._display}`);
    }

    _loadDynavlight() {
        try {
            let configDir = GLib.get_user_config_dir();
            let dynavlightFile = GLib.build_filenamev([configDir, 'dynavlight', 'current_level']);
            
            if (GLib.file_test(dynavlightFile, GLib.FileTest.EXISTS)) {
                let [ok, contents] = GLib.file_get_contents(dynavlightFile);
                if (ok) {
                    let contentStr = imports.byteArray.toString(contents);
                    this._currentLevel = parseFloat(contentStr.trim());
                    if (this._currentLevel < 0.1 || this._currentLevel > 1.0) {
                        this._currentLevel = 0.8;
                    }
                    log(`Dynavlight: Niveau chargé: ${this._currentLevel}`);
                    return;
                }
            }
        } catch (e) {
            log(`Dynavlight: Erreur chargement: ${e}`);
        }
        
        this._currentLevel = 0.8;
    }

    _saveDynavlight(value) {
        try {
            let configDir = GLib.get_user_config_dir();
            let dynavlightDir = GLib.build_filenamev([configDir, 'dynavlight']);
            
            GLib.mkdir_with_parents(dynavlightDir, 0o755);
            
            let dynavlightFile = GLib.build_filenamev([dynavlightDir, 'current_level']);
            GLib.file_set_contents(dynavlightFile, value.toString());
        } catch (e) {
            log(`Dynavlight: Erreur sauvegarde: ${e}`);
        }
    }

    _buildMenu() {
    // Menu title
        let titleItem = new PopupMenu.PopupMenuItem('Dynavlight', {
            reactive: false,
            can_focus: false
        });
        titleItem.label.set_style('font-weight: bold;');
        this.menu.addMenuItem(titleItem);

    // Separator
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

    // Brightness slider
        this._sliderItem = new PopupMenu.PopupBaseMenuItem({ activate: false });
        this._slider = new Slider.Slider(this._currentLevel);
        
        this._slider.connect('notify::value', this._onSliderChanged.bind(this));
        this._sliderItem.add(this._slider);
        this.menu.addMenuItem(this._sliderItem);

    // Label for the percentage
        this._percentageItem = new PopupMenu.PopupMenuItem('', {
            reactive: false,
            can_focus: false
        });
        this._updatePercentageLabel();
        this.menu.addMenuItem(this._percentageItem);

    // Separator
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

    // Display info
        this._displayItem = new PopupMenu.PopupMenuItem(`Écran: ${this._display}`, {
            reactive: false,
            can_focus: false
        });
        this._displayItem.label.set_style('font-size: 0.9em; color: #888;');
        this.menu.addMenuItem(this._displayItem);

    // Apply initial level
        this._applyDynavlight(this._currentLevel);
    }

    _updatePercentageLabel() {
        let percentage = Math.round(this._currentLevel * 100);
        this._percentageItem.label.text = `${percentage}%`;
        this._percentageItem.label.set_style('font-size: 1.2em; font-weight: bold; text-align: center;');
    }

    _onSliderChanged() {
        let value = this._slider.value;
        
    // Clamp between 10% and 100%
        if (value < 0.1) value = 0.1;
        if (value > 1.0) value = 1.0;
        
        this._currentLevel = value;
        this._updatePercentageLabel();
        this._applyDynavlight(value);
        this._saveDynavlight(value);
    }

    _applyDynavlight(value) {
        try {
            let cmd = `xrandr --output ${this._display} --brightness ${value}`;
            GLib.spawn_command_line_async(cmd);
            log(`Dynavlight: Appliqué ${value} sur ${this._display}`);
        } catch (e) {
            log(`Dynavlight: Erreur xrandr: ${e}`);
        }
    }

    destroy() {
        super.destroy();
    }
});

// Global variable for the indicator
let dynavlightIndicator;

function init() {
    log('Dynavlight: Initialisation');
}

function enable() {
    log('Dynavlight: Activation');
    
    dynavlightIndicator = new DynavlightIndicator();
    
    // Add to status panel
    Main.panel.addToStatusArea('dynavlight-indicator', dynavlightIndicator);
    
    log('Dynavlight: Activé avec succès');
}

function disable() {
    log('Dynavlight: Désactivation');
    
    if (dynavlightIndicator) {
        dynavlightIndicator.destroy();
        dynavlightIndicator = null;
    }
    
    log('Dynavlight: Désactivé');
}