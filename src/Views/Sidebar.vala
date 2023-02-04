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
[GtkTemplate (ui = "/co/tauos/Enigma/sidebar.ui")]
public class Enigma.Sidebar : He.Bin {
    [GtkChild]
    public unowned Gtk.ListView lv;


    public DocViewModel? view_model { get; set; }
    public ObservableList<Doc>? docs { get; set; }
    public Gtk.SingleSelection? ss {get; construct;}

    Doc? _selected_doc;
    public Doc? selected_doc {
        get { return _selected_doc; }
        set {
            if (value == _selected_doc)
                return;

            if (value != null)
                _selected_doc = value;
        }
    }

    public Sidebar () {
        Object (
            ss: ss
        );
    }
    construct {
        ss.bind_property ("selected", this, "selected-doc", DEFAULT, (_, from, ref to) => {
            var pos = (uint) from;
            if (pos != Gtk.INVALID_LIST_POSITION)
                to.set_object (ss.model.get_item (pos));
            return true;
        });
    }

    public signal void new_doc_requested ();
}

