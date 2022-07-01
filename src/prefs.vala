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
    [GtkTemplate (ui = "/co/tauos/Enigma/prefs.ui")]
    public class Preferences : He.SettingsWindow {
        [GtkChild]
        unowned Gtk.CheckButton sml;
        [GtkChild]
        unowned Gtk.CheckButton mid;
        [GtkChild]
        unowned Gtk.CheckButton big;
        [GtkChild]
        unowned Gtk.Switch sn;

        public Preferences (MainWindow win) {
            Object (parent: win);

            var settings = new Settings ();
            switch (settings.font_size) {
                case "'small'":
                    sml.set_active (true);
                    break;
                default:
                case "'medium'":
                    mid.set_active (true);
                    break;
                case "'large'":
                    big.set_active (true);
                    break;
            }

            sml.notify["active"].connect (() => {
                settings.font_size = "'small'";
            });
            mid.notify["active"].connect (() => {
                settings.font_size = "'medium'";
            });
            big.notify["active"].connect (() => {
                settings.font_size = "'large'";
            });

            if (settings.show_line_numbers) {
                sn.set_active (true);
            } else {
                sn.set_active (false);
            }

            settings.notify["font-size"].connect (() => {
                switch (settings.font_size) {
                    case "'small'":
                        sml.set_active (true);
                        break;
                    default:
                    case "'medium'":
                        mid.set_active (true);
                        break;
                    case "'large'":
                        big.set_active (true);
                        break;
                }
            });

            sn.notify["active"].connect (() => {
                if (sn.get_active()) {
                    settings.show_line_numbers = true;
                } else {
                    settings.show_line_numbers = false;
                }
            });
            settings.notify["show-line-numbers"].connect (() => {
                if (settings.show_line_numbers) {
                    sn.set_active (true);
                } else {
                    sn.set_active (false);
                }
            });
        }
    }
}
