/*-
 * Copyright (c) 2015-2016 elementary LLC.
 * Copyright (C) 2015-2016 Ikey Doherty <ikey@solus-project.com>
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

/*
 * Code based on budgie-desktop:
 * https://github.com/solus-project/budgie-desktop
 */

namespace Ag {
    public class Agent : PolkitAgent.Listener {
        public override async bool initiate_authentication (string action_id, string message, string icon_name,
            Polkit.Details details, string cookie, GLib.List<Polkit.Identity> identities, GLib.Cancellable? cancellable) throws Polkit.Error {
            if (identities == null) {
                return false;
            }

            var dialog = new PolkitDialog (message, icon_name, cookie, identities, cancellable);
            dialog.done.connect (() => initiate_authentication.callback ());

            dialog.present ();

            Canberra.Context? ca_context = null;
            Canberra.Context.create (out ca_context);
            if (ca_context != null) {
                ca_context.change_props (Canberra.PROP_CANBERRA_XDG_THEME_NAME, "elementary",
                                         Canberra.PROP_MEDIA_LANGUAGE, "");
                ca_context.open ();
                ca_context.play (0, Canberra.PROP_EVENT_ID, "dialog-question");
            }

            yield;

            dialog.destroy ();

            if (dialog.was_canceled) {
                throw new Polkit.Error.CANCELLED ("Authentication dialog was dismissed by the user");
            }

            return true;
        }
    }
}
