/*
* Copyright (c) 2023 Fyra Labs
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
public class Enigma.Application : He.Application {
    private const GLib.ActionEntry app_entries[] = {
        { "quit", quit },
    };

    public Application () {
        base (Config.APP_ID, ApplicationFlags.HANDLES_OPEN);
    }

    public static int main (string[] args) {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        var app = new Enigma.Application ();
        return app.run (args);
    }

    protected override void startup () {
        Gdk.RGBA accent_color = { 0 };
        accent_color.parse("#268EF9");
        default_accent_color = He.Color.from_gdk_rgba(accent_color);

        resource_base_path = "/co/tauos/Enigma";

        base.startup ();

        typeof(GtkSource.View).ensure ();
        typeof (Sidebar).ensure ();
        typeof (ContentView).ensure ();

        add_action_entries (app_entries, this);
    }

    protected override void activate () {
        var repo = new DocRepository ();
        var view_model = new DocViewModel (repo);

        var window = new MainWindow (this, view_model);
        window.present ();
    }

    public override void open (File[] files, string hint) {
		base.open (files, hint);
        var repo = new DocRepository ();
        var view_model = new DocViewModel (repo);
        var window = new MainWindow (this, view_model);
        window.load(files[0]);
        window.present ();
	}

    public MainWindow? get_last_window () {
        unowned List<Gtk.Window> windows = get_windows ();
        return windows.length () > 0 ? windows.last ().data as MainWindow : null;
    }
}
