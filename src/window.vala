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
        unowned Gtk.MenuButton menu_button;
        [GtkChild]
        unowned Gtk.Button new_button;
        [GtkChild]
        unowned Gtk.Button open_button;
        [GtkChild]
        unowned Gtk.Button save_as_button;
        [GtkChild]
        unowned Gtk.TextView text_box;
        [GtkChild]
        unowned Gtk.SearchEntry search_entry;

        private string _file_name = null;
        public string file_name {
            get { return _file_name; }
            set {
                _file_name = value;
            }
        }

        private string _file_name_ext = null;
        public string file_name_ext {
            get { return _file_name_ext; }
            set {
                _file_name_ext = value;
            }
        }

        private string _file_line_count = null;
        public string file_line_count {
            get { return _file_line_count; }
            set {
                _file_line_count = value;
            }
        }

        private bool _modified = false;
        public bool modified {
            get { return _modified; }
            set {
                _modified = value;
            }
        }

        public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              { ACTION_ABOUT, action_about },
        };

        public He.Application app { get; construct; }
        public MainWindow (He.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: Config.APP_ID,
                title: "Enigma"
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

            // Main View
            var builder = new Gtk.Builder.from_resource ("/co/tauos/Enigma/menu.ui");
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/co/tauos/Enigma/style.css");
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            theme.add_resource_path ("/co/tauos/Enigma/");

            // Text View
            new_button.clicked.connect (() => on_new_button_clicked);
            open_button.clicked.connect (() => { open.begin (); });
            save_as_button.clicked.connect (() => { save.begin (); });
            text_box.get_buffer ().changed.connect (() => on_text_box_changed);

            file_name = "New File";
            file_name_ext = "new_file.txt";
            file_line_count = "%d".printf(get_lines ()) + (_(" lines."));

            Timeout.add_seconds (1, () => {
                file_line_count = "%d".printf(get_lines ()) + (_(" lines."));
                return true;
            });

            // Window
            this.set_size_request (360, 360);
            this.show ();
        }

        [GtkCallback]
        public void on_search_activate () {
            var search_str = search_entry.get_text();
            Gtk.TextIter start_iter, end_iter, match_start, match_end;
            text_box.get_buffer ().get_bounds (out start_iter, out end_iter);
            bool found = start_iter.forward_search (search_str, 0, out match_start, out match_end, end_iter);
            if (found) {
                text_box.get_buffer ().select_range (match_start, match_end);
            }
        }

        public void on_new_button_clicked () {
            file_name = null;
            file_name_ext = null;
            file_line_count = null;
            modified = false;
        }

        public async void open () {
            var file = yield Utils.display_open_dialog ();
            string file_path = file.get_path ();
            string text;
            try {
                GLib.FileUtils.get_contents (file_path, out text);
                text_box.get_buffer ().set_text (text);
                file_name = file.get_basename ().replace (".txt", "");
                file_name_ext = file.get_basename ();
                file_line_count = "%d".printf(get_lines ()) + (_(" lines."));
            } catch (Error err) {
                print (err.message);
            }
        }

        public async void save () {
            var file = yield Utils.display_save_dialog ();
            Gtk.TextIter start, end;
            text_box.get_buffer ().get_bounds (out start, out end);
            try {
                GLib.FileUtils.set_contents (file.get_path (), text_box.get_buffer ().get_text (start, end, false));
                modified = false;
            } catch (Error err) {
                print (err.message);
            }
        }

        public void on_text_box_changed () {
            modified = true;
            file_line_count = "%d".printf(get_lines ()) + (_(" lines."));
        }

        public int get_lines () {
            Gtk.TextIter start, end;
            text_box.get_buffer ().get_bounds (out start, out end);
            var buffer = text_box.get_buffer ().get_text (start, end, false);
            int i = 0;
            try {
                GLib.MatchInfo match;
                var reg = new Regex("(?m)(.*$)");
                if (reg.match (buffer, 0, out match)) {
                    do {
                        i++;
                    } while (match.next ());
                }
            } catch (Error e) {
                warning (e.message);
            }

            var lines = i/2;

            return lines;
        }

        public void action_about () {
            string COPYRIGHT = "Copyright \xc2\xa9 2022 Fyra Labs\n";

            string[] AUTHORS = {
                "Lains",
            };
            Gtk.show_about_dialog (
                                   this,
                                   "program-name", "Enigma" + Config.NAME_SUFFIX,
                                   "logo-icon-name", Config.APP_ID,
                                   "version", Config.VERSION,
                                   "comments", _("A simple text editor."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "artists", null,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
                                   "translator-credits", _("translator-credits")
                                  );
        }
    }
}