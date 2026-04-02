/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

/**
 * Class used by GcrAgent to ask for credentials.
 * To get credentials, connect to `response` signal.
 * Gtk.ResponseType.APPLY means that continue button was pressed.
 * Everything else should be treated as cancel.
 */
public sealed class Ag.GcrPasswordDialog : Granite.MessageDialog, PantheonWayland.ExtendedBehavior {
    public Gcr.Prompt prompt { private get; construct; }
    public unowned string password { get { return password_entry.text; } }

    private Gtk.PasswordEntry password_entry;

    public GcrPasswordDialog (Gcr.Prompt prompt) {
        Object (prompt: prompt);
    }

    construct {
        title = prompt.title;
        primary_text = prompt.description;
        secondary_text = prompt.message;
        image_icon = new ThemedIcon ("dialog-password");

        password_entry = new Gtk.PasswordEntry () {
            activates_default = true,
            hexpand = true,
            show_peek_icon = true
        };

        var password_feedback = new Gtk.Label (prompt.warning) {
            justify = RIGHT,
            max_width_chars = 40,
            wrap = true,
            xalign = 1
        };
        password_feedback.add_css_class (Granite.CssClass.ERROR);

        var feedback_revealer = new Gtk.Revealer () {
            child = password_feedback,
            reveal_child = prompt.warning != null
        };

        var credentials_box = new Granite.Box (VERTICAL, HALF);
        credentials_box.append (password_entry);
        credentials_box.append (feedback_revealer);

        custom_bin.append (credentials_box);

        add_button (prompt.cancel_label, Gtk.ResponseType.CANCEL);

        unowned var authenticate_button = (Gtk.Button) add_button (prompt.continue_label, Gtk.ResponseType.APPLY);
        authenticate_button.receives_default = true;
        authenticate_button.add_css_class (Granite.CssClass.SUGGESTED);

        default_widget = authenticate_button;
        focus_widget = password_entry;

        child.realize.connect (() => {
            connect_to_shell ();
            set_keep_above ();
            make_centered ();
            make_modal (true);

            unowned var surface = get_surface ();
            if (surface is Gdk.Toplevel) {
                ((Gdk.Toplevel) surface).inhibit_system_shortcuts (null);
            }
        });
    }
}
