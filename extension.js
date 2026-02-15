/* extension.js
 *
 * Extension GNOME Shell - Contrôle Luminosité Logicielle
 * Compatible GNOME Shell 3.36 - 46+
 */

const { GObject, St, Clutter, Gio, GLib } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Slider = imports.ui.slider;

// Classe de l'indicateur de luminosité
const BrightnessIndicator = GObject.registerClass(
class BrightnessIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Brightness Control');

        // Icône dans le panneau système (en haut à droite)
        this._icon = new St.Icon({
            icon_name: 'display-brightness-symbolic',
            style_class: 'system-status-icon',
        });
        this.add_child(this._icon);

        // Détection de l'écran
        this._detectDisplay();
        
        // Charger la luminosité sauvegardée
        this._loadBrightness();

        // Construire le menu
        this._buildMenu();
        
        log('Extension Brightness: Initialisée avec succès');
    }

    _detectDisplay() {
        try {
            let [ok, stdout, stderr, status] = GLib.spawn_command_line_sync('xrandr');
            if (ok) {
                let output = imports.byteArray.toString(stdout);
                let lines = output.split('\n');
                
                // Chercher l'écran principal
                for (let line of lines) {
                    if (line.includes('connected primary')) {
                        this._display = line.split(' ')[0];
                        log(`Extension Brightness: Écran principal détecté: ${this._display}`);
                        return;
                    }
                }
                
                // Sinon, prendre le premier connecté
                for (let line of lines) {
                    if (line.includes('connected') && !line.includes('disconnected')) {
                        this._display = line.split(' ')[0];
                        log(`Extension Brightness: Écran détecté: ${this._display}`);
                        return;
                    }
                }
            }
        } catch (e) {
            log(`Extension Brightness: Erreur détection: ${e}`);
        }

        this._display = 'Virtual-1';
        log(`Extension Brightness: Écran par défaut: ${this._display}`);
    }

    _loadBrightness() {
        try {
            let configDir = GLib.get_user_config_dir();
            let brightnessFile = GLib.build_filenamev([configDir, 'brightness-control', 'current_brightness']);
            
            if (GLib.file_test(brightnessFile, GLib.FileTest.EXISTS)) {
                let [ok, contents] = GLib.file_get_contents(brightnessFile);
                if (ok) {
                    let contentStr = imports.byteArray.toString(contents);
                    this._currentBrightness = parseFloat(contentStr.trim());
                    if (this._currentBrightness < 0.1 || this._currentBrightness > 1.0) {
                        this._currentBrightness = 0.8;
                    }
                    log(`Extension Brightness: Luminosité chargée: ${this._currentBrightness}`);
                    return;
                }
            }
        } catch (e) {
            log(`Extension Brightness: Erreur chargement: ${e}`);
        }
        
        this._currentBrightness = 0.8;
    }

    _saveBrightness(value) {
        try {
            let configDir = GLib.get_user_config_dir();
            let brightnessDir = GLib.build_filenamev([configDir, 'brightness-control']);
            
            GLib.mkdir_with_parents(brightnessDir, 0o755);
            
            let brightnessFile = GLib.build_filenamev([brightnessDir, 'current_brightness']);
            GLib.file_set_contents(brightnessFile, value.toString());
        } catch (e) {
            log(`Extension Brightness: Erreur sauvegarde: ${e}`);
        }
    }

    _buildMenu() {
        // Titre du menu
        let titleItem = new PopupMenu.PopupMenuItem('Luminosité', {
            reactive: false,
            can_focus: false
        });
        titleItem.label.set_style('font-weight: bold;');
        this.menu.addMenuItem(titleItem);

        // Séparateur
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // Curseur de luminosité
        this._sliderItem = new PopupMenu.PopupBaseMenuItem({ activate: false });
        this._slider = new Slider.Slider(this._currentBrightness);
        
        this._slider.connect('notify::value', this._onSliderChanged.bind(this));
        this._sliderItem.add(this._slider);
        this.menu.addMenuItem(this._sliderItem);

        // Label pour le pourcentage
        this._percentageItem = new PopupMenu.PopupMenuItem('', {
            reactive: false,
            can_focus: false
        });
        this._updatePercentageLabel();
        this.menu.addMenuItem(this._percentageItem);

        // Séparateur
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // Info sur l'écran
        this._displayItem = new PopupMenu.PopupMenuItem(`Écran: ${this._display}`, {
            reactive: false,
            can_focus: false
        });
        this._displayItem.label.set_style('font-size: 0.9em; color: #888;');
        this.menu.addMenuItem(this._displayItem);

        // Appliquer la luminosité initiale
        this._applyBrightness(this._currentBrightness);
    }

    _updatePercentageLabel() {
        let percentage = Math.round(this._currentBrightness * 100);
        this._percentageItem.label.text = `${percentage}%`;
        this._percentageItem.label.set_style('font-size: 1.2em; font-weight: bold; text-align: center;');
    }

    _onSliderChanged() {
        let value = this._slider.value;
        
        // Limiter entre 10% et 100%
        if (value < 0.1) value = 0.1;
        if (value > 1.0) value = 1.0;
        
        this._currentBrightness = value;
        this._updatePercentageLabel();
        this._applyBrightness(value);
        this._saveBrightness(value);
    }

    _applyBrightness(value) {
        try {
            let cmd = `xrandr --output ${this._display} --brightness ${value}`;
            GLib.spawn_command_line_async(cmd);
            log(`Extension Brightness: Appliqué ${value} sur ${this._display}`);
        } catch (e) {
            log(`Extension Brightness: Erreur xrandr: ${e}`);
        }
    }

    destroy() {
        super.destroy();
    }
});

// Variable globale pour l'indicateur
let brightnessIndicator;

function init() {
    log('Extension Brightness: Initialisation');
}

function enable() {
    log('Extension Brightness: Activation');
    
    brightnessIndicator = new BrightnessIndicator();
    
    // Ajouter au panneau système (en haut à droite)
    Main.panel.addToStatusArea('brightness-indicator', brightnessIndicator);
    
    log('Extension Brightness: Activée avec succès');
}

function disable() {
    log('Extension Brightness: Désactivation');
    
    if (brightnessIndicator) {
        brightnessIndicator.destroy();
        brightnessIndicator = null;
    }
    
    log('Extension Brightness: Désactivée');
}
