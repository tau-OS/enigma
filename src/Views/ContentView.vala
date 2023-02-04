/*
* Copyright (C) 2017-2022 Lains
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
[GtkTemplate (ui = "/co/tauos/Enigma/contentview.ui")]
public class Enigma.ContentView : He.Bin {
    delegate void HookFunc ();
    public signal void clicked ();

    [GtkChild]
    public unowned GtkSource.View textbox;
    [GtkChild]
    public unowned Gtk.SearchEntry search_entry;
    [GtkChild]
    unowned Gtk.MenuButton menu_button;
    [GtkChild]
    unowned Gtk.Button open_button;
    [GtkChild]
    unowned Gtk.Button save_as_button;
    [GtkChild]
    unowned Gtk.Box vim_status_bar;
    [GtkChild]
    unowned Gtk.Label command_bar;
    [GtkChild]
    unowned Gtk.Label command_text;

    Binding? text_binding;

    public DocViewModel? vm {get; set;}

    private GtkSource.VimIMContext? vim_im_context;
    private Gtk.EventControllerKey? vim_event_controller;

    Doc? _doc;
    public Doc? doc {
        get { return _doc; }
        set {
            if (value == _doc)
                return;

            text_binding?.unbind ();

            _doc = value;

            text_binding = _doc?.bind_property ("text", textbox.get_buffer (), "text", SYNC_CREATE|BIDIRECTIONAL);

            var settings = new Settings ();
            switch (settings.font_size) {
                case "'small'":
                textbox.add_css_class ("sml-font");
                textbox.remove_css_class ("med-font");
                textbox.remove_css_class ("big-font");
                break;
                default:
                case "'medium'":
                textbox.remove_css_class ("sml-font");
                textbox.add_css_class ("med-font");
                textbox.remove_css_class ("big-font");
                break;
                case "'large'":
                textbox.remove_css_class ("sml-font");
                textbox.remove_css_class ("med-font");
                textbox.add_css_class ("big-font");
                break;
            }
            settings.notify["font-size"].connect (() => {
                switch (settings.font_size) {
                    case "'small'":
                    textbox.add_css_class ("sml-font");
                    textbox.remove_css_class ("med-font");
                    textbox.remove_css_class ("big-font");
                    break;
                    default:
                    case "'medium'":
                    textbox.remove_css_class ("sml-font");
                    textbox.add_css_class ("med-font");
                    textbox.remove_css_class ("big-font");
                    break;
                    case "'large'":
                    textbox.remove_css_class ("sml-font");
                    textbox.remove_css_class ("med-font");
                    textbox.add_css_class ("big-font");
                    break;
                }
            });

            textbox.grab_focus ();
        }
    }

    public ContentView (DocViewModel? vm) {
        Object (
            vm: vm
        );
    }

    construct {
        var builder = new Gtk.Builder.from_resource ("/co/tauos/Enigma/menu.ui");
        menu_button.menu_model = (MenuModel)builder.get_object ("menu");

        open_button.clicked.connect (() => { open.begin (); });
        save_as_button.clicked.connect (() => { save.begin (); });

        var settings = new Settings ();
        if (settings.settings.get_boolean ("vim-emulation")) {
            setup_vim_emulation ();
        }

        settings.settings.changed.connect((key) => {
            if (key != "vim-emulation") return;
            if (settings.settings.get_boolean ("vim-emulation")) {
                this.setup_vim_emulation ();
            } else {
                this.cleanup_vim_emulation ();
            }
        });

        settings.settings.bind ("show-line-numbers", textbox, "show-line-numbers", DEFAULT);
        settings.settings.bind ("hilight-curr-line", textbox, "highlight-current-line", DEFAULT);
        settings.settings.bind ("hilight-brackets", ((GtkSource.Buffer)textbox.get_buffer ()), "highlight-matching-brackets", DEFAULT);
    }

    public async void open () {
        var file = yield Utils.display_open_dialog ();
        string file_path = file.get_path ();
        string text;
        try {
            GLib.FileUtils.get_contents (file_path, out text);
            if (file != null && text != null) {
                textbox.get_buffer ().set_text (text);
            } else {
                textbox.get_buffer ().set_text ("");
            }
        } catch (Error err) {
            print (err.message);
        }
    }

    public async void save () {
        var file = yield Utils.display_save_dialog ();
        Gtk.TextIter start, end;
        textbox.get_buffer ().get_bounds (out start, out end);
        try {
            GLib.FileUtils.set_contents (file.get_path (), textbox.get_buffer ().get_text (start, end, false));
        } catch (Error err) {
            print (err.message);
        }
    }

    public signal void doc_update_requested (Doc doc);
    void on_text_updated () {
        doc_update_requested (doc);
    }

    private void setup_vim_emulation () {
        cleanup_vim_emulation();

        vim_im_context = new GtkSource.VimIMContext();
        vim_event_controller = new Gtk.EventControllerKey();

        vim_event_controller.set_im_context(vim_im_context);
        vim_event_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);

        vim_im_context.bind_property("command-bar-text", command_bar, "label", 0);
        vim_im_context.bind_property("command-text", command_text, "label", 0);

        textbox.add_controller (vim_event_controller);
        vim_im_context.set_client_widget (textbox);
        vim_status_bar.visible = true;
    }

    private void cleanup_vim_emulation () {
        if (vim_event_controller != null) textbox.remove_controller (vim_event_controller);
        if (vim_im_context != null) vim_im_context.set_client_widget (null);

        vim_im_context = null;
        vim_event_controller = null;
        vim_status_bar.visible = false;
    }

    [GtkCallback]
        public void on_search_activate () {
            var search_str = search_entry.get_text();
            Gtk.TextIter start_iter, end_iter, match_start, match_end;
            textbox.get_buffer ().get_bounds (out start_iter, out end_iter);
            bool found = start_iter.forward_search (search_str, 0, out match_start, out match_end, end_iter);
            if (found) {
                textbox.get_buffer ().select_range (match_start, match_end);
            }
        }
}

