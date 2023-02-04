/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/
namespace Enigma {
    [GtkTemplate (ui = "/co/tauos/Enigma/main_window.ui")]
    public class MainWindow : He.ApplicationWindow {
        delegate void HookFunc ();
        public signal void clicked ();

        [GtkChild]
        public unowned Sidebar sidebar;

        public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public const string ACTION_PREFS = "action_prefs";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              { ACTION_ABOUT, action_about },
              { ACTION_PREFS, action_prefs },
        };

        // Custom
        public MainWindow? mw {get; set;}
        public Gtk.SelectionModel? ss {get; set;}

        // Etc
        public DocViewModel view_model { get; construct; }

        public He.Application app { get; construct; }
        public MainWindow (He.Application application, DocViewModel view_model) {
            GLib.Object (
                application: application,
                app: application,
                view_model: view_model,
                icon_name: Config.APP_ID
            );
        }

        construct {
            // Actions
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
            app.set_accels_for_action("app.quit", {"<Ctrl>q"});

            var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            theme.add_resource_path ("/co/tauos/Enigma/");

            // Window
            this.set_size_request (360, 360);
            this.show ();
            this.mw = (MainWindow) app.get_active_window ();
        }

        [GtkCallback]
        void on_new_doc_requested () {
            view_model.create_new_doc (null);
        }

        [GtkCallback]
        public void on_doc_update_requested (Doc doc) {
            view_model.update_doc (doc);
        }

        public void action_about () {
             var about = new He.AboutWindow (
                 this,
                 "Enigma" + Config.NAME_SUFFIX,
                 Config.APP_ID,
                 Config.VERSION,
                 Config.APP_ID,
                 "https://github.com/tau-OS/enigma/tree/main/po",
                 "https://github.com/tau-OS/enigma/issues",
                 "catalogue://co.tauos.Enigma",
                 {},
                 {"Lains", "Lea"},
                 2022,
                 He.AboutWindow.Licenses.GPLv3,
                 He.Colors.BLUE
             );
             about.present ();
        }

        public void action_prefs () {
            var settings = new Preferences (this);
            settings.parent = this;
            settings.present ();
        }

        public void load(GLib.File file) {
            uint8[] text;
            try {
                file.load_contents (null, out text, null);
                
            } catch (Error err) {
                print (err.message);
            }
        }
    }
}
