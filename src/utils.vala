namespace Enigma.Utils {
    public unowned MainWindow win;
    public async File? display_open_dialog () {
        var dialog = new Gtk.FileChooserNative (null, win, Gtk.FileChooserAction.OPEN, null, null);
        dialog.set_transient_for(win);
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

    public async File? display_save_dialog () {
        var dialog = new Gtk.FileChooserNative (null, win, Gtk.FileChooserAction.SAVE, null, null);
        dialog.set_transient_for(win);
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