/*
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

public class Ag.PortalDialog : Gtk.Window, PantheonWayland.ExtendedBehavior {
    /**
     * The {@link PortalDialog.ResponseType} that has been selected by the user
     */
    public signal void response (ResponseType response);

    /**
     * The {@link GLib.Icon} that is used to display the primary_icon representing the app making the request
     */
    public GLib.Icon primary_icon { get; set; }

    /**
     * The {@link GLib.Icon} that is used to display a secondary_icon representing the action to be performed
     */
    public GLib.Icon secondary_icon { get; set; }

    /**
     * The secondary text, body of the dialog.
     */
    public string secondary_text { get; set; }

    /**
     * The child widget for the content area
     */
    public Gtk.Widget content { get; set; }

    /**
     * The label of the button which denies access
     */
    public string cancel_label { get; set; }

    /**
     * The label of the button which allows access
     */
    public string allow_label { get; set; }

    /**
     * Whether the allow button should be disabled
     */
    public bool form_valid { get; set; default = true; }

    public ActionType action_type { get; set; default = SUGGESTED; }

    public enum ActionType {
        SUGGESTED,
        DESTRUCTIVE
    }

    public enum ResponseType {
        ALLOW,
        CANCEL,
        DELETE_EVENT;

        // Convert to response ID expected by portal backends
        public uint32 to_id () {
            switch (this) {
                case ALLOW:
                    return 0;
                case CANCEL:
                    return 1;
                default:
                case DELETE_EVENT:
                    return 2;
            }
        }
    }

    /**
     * The parent window identifier as described by https://flatpak.github.io/xdg-desktop-portal/docs/window-identifiers.html
     */
    public string parent_handle { get; set; }

    private Granite.Box button_box;

    construct {
        var primary_icon = new Gtk.Image.from_icon_name ("application-default-icon") {
            halign = START,
            icon_size = LARGE
        };

        var secondary_icon = new Gtk.Image.from_icon_name ("preferences-system-privacy") {
            halign = END,
            icon_size = LARGE
        };

        var overlay = new Gtk.Overlay () {
            child = secondary_icon,
            halign = CENTER
        };
        overlay.add_overlay (primary_icon);

        var header_label = new Granite.HeaderLabel ("") {
            size = H3
        };

        var header = new Granite.Box (VERTICAL);
        header.append (overlay);
        header.append (header_label);

        var cancel_button = new Gtk.Button.with_label (_("Don't Allow"));

        var allow_button = new Gtk.Button.with_label (_("Allow")) {
            receives_default = true
        };
        allow_button.add_css_class (Granite.CssClass.SUGGESTED);

        button_box = new Granite.Box (HORIZONTAL, HALF) {
            homogeneous = true,
            valign = END
        };
        button_box.append (cancel_button);
        button_box.append (allow_button);

        var toolbarview = new Granite.ToolBox ();
        toolbarview.add_bottom_bar (button_box);
        toolbarview.add_top_bar (header);

        child = toolbarview;

        default_width = 325;
        default_widget = allow_button;
        modal = true;

        // We need to hide the title area
        titlebar = new Gtk.Grid () {
            visible = false
        };

        add_css_class ("dialog");

        bind_property ("primary-icon", primary_icon, "gicon");
        bind_property ("secondary-icon", secondary_icon, "gicon");
        bind_property ("content", toolbarview, "content");
        bind_property ("title", header_label, "label");
        bind_property ("secondary-text", header_label, "secondary-text");
        bind_property ("form-valid", allow_button, "sensitive");
        bind_property ("allow-label", allow_button, "label");
        bind_property ("cancel-label", cancel_button, "label");

        notify["action-type"].connect (() => {
            if (action_type == SUGGESTED) {
                allow_button.add_css_class (Granite.CssClass.SUGGESTED);
                cancel_button.receives_default = false;
                allow_button.receives_default = true;
                default_widget = allow_button;
            } else {
                allow_button.add_css_class (Granite.CssClass.DESTRUCTIVE);
                allow_button.receives_default = false;
                cancel_button.receives_default = true;
                default_widget = cancel_button;
            }
        });

        child.realize.connect (on_realize);

        allow_button.clicked.connect (() => response (ALLOW));
        cancel_button.clicked.connect (() => response (CANCEL));
        close_request.connect (() => { response (DELETE_EVENT); });
    }

    private void on_realize () {
        connect_to_shell ();
        set_keep_above ();
        make_centered ();
        make_modal (true);

        var surface = get_surface ();
        if (surface is Gdk.Toplevel) {
            ((Gdk.Toplevel) surface).inhibit_system_shortcuts (null);
        }
    }
}
