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
public class Enigma.DocRepository : Object {
    const string FILENAME = "saved_docs.json";

    Queue<Doc> insert_queue = new Queue<Doc> ();
    public Queue<Doc> update_queue = new Queue<Doc> ();
    Queue<string> delete_queue = new Queue<string> ();

    public async List<Doc> get_docs () {
        return new List<Doc> ();
    }

    public void insert_doc (Doc doc) {
        insert_queue.push_tail (doc);
    }

    public void update_doc (Doc doc) {
        update_queue.push_tail (doc);
    }

    public void delete_doc (string id) {
        delete_queue.push_tail (id);
    }

    public async bool save () {
        var docs = yield get_docs ();

        Doc? doc = null;
        while ((doc = update_queue.pop_head ()) != null) {
            var current_doc = search_doc_by_id (docs, doc.id);

            if (current_doc == null) {
                insert_queue.push_tail (doc);
                continue;
            }
            current_doc.title = doc.title;
            current_doc.subtitle = doc.subtitle;
            current_doc.text = doc.text;
        }

        string? doc_id = null;
        while ((doc_id = delete_queue.pop_head ()) != null) {
            doc = search_doc_by_id (docs, doc_id);

            if (doc == null)
                continue;

            docs.remove (doc);
        }

        doc = null;
        while ((doc = insert_queue.pop_head ()) != null)
            docs.append (doc);

        var json_array = new Json.Array ();
        foreach (var item in docs)
            json_array.add_element (item.to_json ());

        var node = new Json.Node (ARRAY);
        node.set_array (json_array);

        var str = Json.to_string (node, false);

        try {
            return yield FileUtils.create_text_file (FILENAME, str);
        } catch (Error err) {
              critical ("Error: %s", err.message);
              return false;
        }
    }

    public inline Doc? search_doc_by_id (List<Doc> docs, string id) {
        unowned var link = docs.search<string> (id, (doc, id) => strcmp (doc.id, id));
        return link?.data;
    }
}
