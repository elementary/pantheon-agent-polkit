/*-
 * Copyright (c) 2015-2016 elementary LLC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Adam Bieńkowski <donadigos159@gmail.com>
 */

namespace Ag {
    public class Agent : PolkitAgent.Listener {
        public Agent () {
            register_with_session.begin ((obj, res)=> {
                bool success = register_with_session.end (res);
                if (!success) {
                    critical ("Failed to register with Session manager");
                }
            });
        }

        public override async bool initiate_authentication (string action_id, string message, string icon_name,
            Polkit.Details details, string cookie, GLib.List<Polkit.Identity?>? identities, GLib.Cancellable cancellable) {
            if (identities == null) {
                return false;
            }

            if (icon_name == "") {
                icon_name = "dialog-password";
            }

            var dialog = new Widgets.PolkitDialog (message, icon_name, cookie, identities, cancellable);
            dialog.done.connect (() => initiate_authentication.callback ());

            dialog.show_all ();
            yield;

            dialog.destroy ();
            return true;
        }

        private async bool register_with_session () {
            return true;
        }
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var agent = new Agent ();
        int pid = Posix.getpid ();

        Polkit.Subject? subject = null;
        try {
            subject = Polkit.UnixSession.new_for_process_sync (pid, null);
        } catch (Error e) {
            critical ("Unable to initiate Polkit: %s", e.message);
            return 1;
        }

        try {
            PolkitAgent.register_listener (agent, subject, null);
        } catch (Error e) {
            return 1;
        }

        Gtk.main ();
        return 0;
    }
}