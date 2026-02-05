/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

/**
 * Class used by GcrAgent to ask for confirmation.
 * To get status, connect to `response` signal.
 * Gtk.ResponseType.APPLY means that continue button was pressed.
 * Everything else should be treated as cancel.
 */
public sealed class Ag.GcrConfirmDialog : Granite.MessageDialog, PantheonWayland.ExtendedBehavior {
    public Gcr.Prompt prompt { private get; construct; }

    public GcrConfirmDialog (Gcr.Prompt prompt) {
        Object (prompt: prompt);
    }

    construct {
        title = prompt.title;
        primary_text = prompt.description;
        secondary_text = prompt.message;
        image_icon = new ThemedIcon ("dialog-question");

        add_button (prompt.cancel_label, Gtk.ResponseType.CANCEL);

        unowned var authenticate_button = (Gtk.Button) add_button (prompt.continue_label, Gtk.ResponseType.APPLY);
        authenticate_button.receives_default = true;
        authenticate_button.add_css_class (Granite.CssClass.SUGGESTED);

        default_widget = authenticate_button;

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
