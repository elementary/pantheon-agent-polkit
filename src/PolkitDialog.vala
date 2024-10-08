/*-
 * Copyright (c) 2015-2019 elementary, Inc. (https://elementary.io)
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

public class Ag.PolkitDialog : Granite.MessageDialog, PantheonWayland.ExtendedBehavior {
    public signal void done ();
    public bool was_canceled = false;

    private PolkitAgent.Session? pk_session = null;
    private Polkit.Identity? pk_identity = null;
    private unowned Cancellable cancellable;

    private ulong error_signal_id;
    private ulong request_signal_id;
    private ulong info_signal_id;
    private ulong complete_signal_id;

    private unowned List<Polkit.Identity?>? idents;
    private string cookie;
    private bool canceling = false;

    private Gtk.Revealer feedback_revealer;
    private Gtk.Label password_label;
    private Gtk.Label password_feedback;
    private Gtk.Entry password_entry;
    private Gtk.ComboBox idents_combo;

    public PolkitDialog (string message, string icon_name, string _cookie,
                         List<Polkit.Identity?>? _idents, GLib.Cancellable _cancellable) {
        Object (
            title: _("Authentication Dialog")
        );

        idents = _idents;
        cookie = _cookie;
        cancellable = _cancellable;
        cancellable.cancelled.connect (cancel);

        primary_text = _("Authentication Required");
        secondary_text = message;

        password_entry = new Gtk.Entry () {
            activates_default = true,
            hexpand = true,
            input_purpose = PASSWORD,
            primary_icon_name = "dialog-password-symbolic",
            primary_icon_tooltip_text = _("Password")
        };

        password_feedback = new Gtk.Label (null) {
            justify = RIGHT,
            max_width_chars = 40,
            wrap = true,
            xalign = 1
        };
        password_feedback.add_css_class (Granite.STYLE_CLASS_ERROR);

        feedback_revealer = new Gtk.Revealer () {
            child = password_feedback
        };

        idents_combo = new Gtk.ComboBox () {
            hexpand = true
        };
        idents_combo.changed.connect (on_ident_changed);

        Gtk.CellRenderer renderer = new Gtk.CellRendererPixbuf ();
        idents_combo.pack_start (renderer, false);
        idents_combo.add_attribute (renderer, "icon-name", 0);

        renderer = new Gtk.CellRendererText ();
        renderer.xpad = 6;
        idents_combo.pack_start (renderer, true);
        idents_combo.add_attribute (renderer, "text", 1);
        idents_combo.set_id_column (1);

        var credentials_box = new Gtk.Box (VERTICAL, 6);
        credentials_box.append (idents_combo);
        credentials_box.append (password_entry);
        credentials_box.append (feedback_revealer);

        image_icon = new ThemedIcon ("dialog-password");

        if (icon_name != "" && Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).has_icon (icon_name)) {
            badge_icon = new ThemedIcon (icon_name);
        }

        custom_bin.append (credentials_box);

        var cancel_button = (Gtk.Button)add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        cancel_button.clicked.connect (() => cancel ());

        var authenticate_button = (Gtk.Button)add_button (_("Authenticate"), Gtk.ResponseType.APPLY);
        authenticate_button.receives_default = true;
        authenticate_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        authenticate_button.clicked.connect (authenticate);

        default_widget = authenticate_button;
        focus_widget = password_entry;

        close.connect (cancel);

        update_idents ();
        select_session ();

        child.realize.connect (() => {
            connect_to_shell ();
            set_keep_above ();
            make_centered ();

            var surface = get_surface ();
            if (surface is Gdk.Toplevel) {
                ((Gdk.Toplevel) surface).inhibit_system_shortcuts (null);
            }
        });
    }

    private void update_idents () {
        var model = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (Polkit.Identity));
        Gtk.TreeIter iter;

        int length = 0;
        int active = 0;

        string? target_user = null;

        foreach (unowned Polkit.Identity? ident in idents) {
            if (ident == null) {
                continue;
            }

            string name = ident.to_string ();

            if (ident is Polkit.UnixUser) {
                unowned Posix.Passwd? pwd = Posix.getpwuid (((Polkit.UnixUser)ident).get_uid ());
                if (pwd != null) {
                    string pw_name = pwd.pw_name;
                    if (target_user == null && length < 2) {
                        target_user = pw_name;
                    }

                    name = pw_name;
                }
            } else if (ident is Polkit.UnixGroup) {
                unowned Posix.Group? gwd = Posix.getgrgid (((Polkit.UnixGroup)ident).get_gid ());
                if (gwd != null) {
                    name = _("Group: %s").printf (gwd.gr_name);
                }
            }

            model.append (out iter);
            model.set (iter, 0, "avatar-default-symbolic", 1, name, 2, ident);

            if (name == Environment.get_user_name ()) {
                active = length;
            }

            length++;
        }

        idents_combo.set_model (model);
        idents_combo.active = active;

        if (length < 2) {
            if (target_user == Environment.get_user_name ()) {
                idents_combo.visible = false;
            } else {
                idents_combo.sensitive = false;
            }
        }
    }

    private void select_session () {
        if (pk_session != null) {
            deselect_session ();
        }

        pk_session = new PolkitAgent.Session (pk_identity, cookie);
        error_signal_id = pk_session.show_error.connect (on_pk_show_error);
        complete_signal_id = pk_session.completed.connect (on_pk_session_completed);
        request_signal_id = pk_session.request.connect (on_pk_request);
        info_signal_id = pk_session.show_info.connect (on_pk_show_info);
        pk_session.initiate ();
    }

    private void deselect_session () {
        if (pk_session != null) {
            SignalHandler.disconnect (pk_session, error_signal_id);
            SignalHandler.disconnect (pk_session, complete_signal_id);
            SignalHandler.disconnect (pk_session, request_signal_id);
            SignalHandler.disconnect (pk_session, info_signal_id);
            pk_session = null;
        }
    }

    private void authenticate () {
        if (pk_session == null) {
            select_session ();
        }

        password_entry.secondary_icon_name = "";
        feedback_revealer.reveal_child = false;

        sensitive = false;
        pk_session.response (password_entry.get_text ());
    }

    private void cancel () {
        canceling = true;
        if (pk_session != null) {
            pk_session.cancel ();
        }

        debug ("Authentication cancelled");
        was_canceled = true;

        canceling = false;
        done ();
    }

    private void on_ident_changed () {
        Gtk.TreeIter iter;

        if (!idents_combo.get_active_iter (out iter)) {
            deselect_session ();
            return;
        }

        var model = idents_combo.get_model ();
        if (model == null) {
            return;
        }

        model.get (iter, 2, out pk_identity, -1);
        select_session ();
    }

    private void on_pk_session_completed (bool authorized) {
        if (!authorized || cancellable.is_cancelled ()) {
            if (!canceling) {
                on_pk_show_error (_("Authentication failed. Please try again."));
            }

            deselect_session ();
            password_entry.set_text ("");
            password_entry.grab_focus ();
            select_session ();
            return;
        } else {
            done ();
        }
        sensitive = true;
    }

    private void on_pk_request (string request, bool echo_on) {
        password_entry.visibility = echo_on;
        if (!request.has_prefix ("Password:")) {
            password_label.label = request;
        }
    }

    private void on_pk_show_error (string text) {
        var width = get_width ();
        var height = get_height ();

        var shake = new Adw.TimedAnimation (
            child, 0, -24, 70,
            new Adw.CallbackAnimationTarget ((val) => {
                child.allocate (
                    width, height, -1,
                    new Gsk.Transform ().translate (Graphene.Point () { x = (int) val })
                );
            })
        ) {
            easing = EASE_OUT_CIRC,
            reverse = true,
        };
        shake.play ();

        int repeat_count = 0;
        ulong iterate = 0;
        iterate = shake.done.connect (() => {
            if (repeat_count == 4) {
                feedback_revealer.reveal_child = true;
                password_entry.secondary_icon_name = "dialog-error-symbolic";
                password_feedback.label = text;
                sensitive = true;
                disconnect (iterate);
                return;
            }

            shake.value_to = -1 * shake.value_to;
            shake.play ();
            repeat_count++;
        });
    }

    private void on_pk_show_info (string text) {
        info (text);
    }
}
