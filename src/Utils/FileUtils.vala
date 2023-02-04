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
namespace Enigma.FileUtils {
    async bool create_text_file (string filename, string contents, Cancellable? cancellable = null) throws Error {
        return yield ThreadUtils.run_in_thread<bool> (() => {
            var dir_path = Path.build_filename (Environment.get_user_data_dir (), "/co.tauos.Enigma/");

            if (DirUtils.create_with_parents (dir_path, 0755) != 0) {
                throw new Error (FileError.quark (), GLib.FileUtils.error_from_errno (errno), "%s", strerror (errno));
            }

            var file_path = Path.build_filename (dir_path, filename);
            GLib.FileUtils.set_contents (file_path, contents);

            return true;
        });
    }
}
