/*
* Copyright (C) 2023 Fyra Labs
*
* This program is free software; you can redistribute it &&/or
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
*/
namespace Enigma.Utils {
    public unowned MainWindow win;
    public async File? display_open_dialog (Gtk.Window? win) {
        var dialog = new Gtk.FileChooserNative (null, win, Gtk.FileChooserAction.OPEN, null, null);
        dialog.set_transient_for(win);
        dialog.modal = true;
        var filter1 = new Gtk.FileFilter ();
        filter1.set_filter_name (_("Text files"));
        filter1.add_pattern ("*.txt");
        dialog.add_filter (filter1);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_("All files"));
        filter.add_pattern ("*");
        dialog.add_filter (filter);

        var response = yield run_dialog_async (dialog);

        if (response == Gtk.ResponseType.ACCEPT) {
            return dialog.get_file ();
        }

        return null;
    }

    public async File? display_save_dialog (Gtk.Window? win) {
        var dialog = new Gtk.FileChooserNative (null, win, Gtk.FileChooserAction.SAVE, null, null);
        dialog.set_transient_for(win);
        dialog.modal = true;
        var filter1 = new Gtk.FileFilter ();
        filter1.set_filter_name (_("Text files"));
        filter1.add_pattern ("*.txt");
        dialog.add_filter (filter1);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_("All files"));
        filter.add_pattern ("*");
        dialog.add_filter (filter);

        var response = yield run_dialog_async (dialog);

        if (response == Gtk.ResponseType.ACCEPT) {
            return dialog.get_file ();
        }

        return null;
    }

    private async Gtk.ResponseType run_dialog_async (Gtk.FileChooserNative dialog) {
        var response = Gtk.ResponseType.CANCEL;

        dialog.response.connect (r => {
        	response = (Gtk.ResponseType) r;

        	run_dialog_async.callback ();
        });

        dialog.show ();

        yield;
        return response;
	}

    
}
