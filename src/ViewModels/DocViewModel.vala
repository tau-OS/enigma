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
public class Enigma.DocViewModel : Object {
    uint timeout_id = 0;

    public ObservableList<Doc> docs { get; default = new ObservableList<Doc> (); }
    public DocRepository? repository { private get; construct; }

    public DocViewModel (DocRepository repository) {
        Object (repository: repository);
    }

    construct {
        populate_docs.begin ();
    }

    public void create_new_doc (Doc? doc) {
        var n = new Doc () {
            title = _("New File"),
            subtitle = "~/doc.txt",
            text = "",
        };

        if (doc == null) {
            docs.add (n);
            repository.insert_doc (n);
        } else {
            docs.add (doc);
            repository.insert_doc (doc);
        }
        save_docs ();
    }

    public void update_doc (Doc? doc) {
        repository.update_doc (doc);
        save_docs ();
    }

    async void populate_docs () {
        var docs = yield repository.get_docs ();
        this.docs.add_all (docs);
    }

    void save_docs () {
        if (timeout_id != 0) {
            Source.remove (timeout_id);
        }

        timeout_id = Timeout.add (500, () => {
            timeout_id = 0;

            repository.save.begin ();

            return Source.REMOVE;
        });
    }
}
