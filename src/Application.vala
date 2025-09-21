/*
 * SPDX-License-Identifier: LGPL-2.1-or-later
 * SPDX-FileCopyrightText: 2023 elementary, Inc. (https://elementary.io)
 */

public class Ag.Application : Gtk.Application {
    public static FPrintManager fingerprint_manager;

    public Application () {
        Object (
            application_id: "io.elementary.PolkitAgent",
            flags: GLib.ApplicationFlags.IS_SERVICE,
            register_session: true
        );
    }

    protected override void startup () {
        base.startup ();

        unowned var granite_settings = Granite.Settings.get_default ();
        unowned var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.notify["prefers-color-scheme"].connect (() =>
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK
        );

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK;

        try {
            Ag.Application.fingerprint_manager = Bus.get_proxy_sync (
                BusType.SYSTEM,
                "net.reactivated.Fprint",
                "/net/reactivated/Fprint/Manager",
                DBusProxyFlags.NONE
            );
        } catch (Error e) {
            warning ("Unable to initialize Fingerprint Manager %s", e.message);
        }

        var agent = new Agent ();
        try {
            var subject = new Polkit.UnixSession.for_process_sync (Posix.getpid (), null);
            agent.register (NONE, subject, resource_base_path, null);
        } catch (Error e) {
            critical ("Unable to initiate Polkit: %s", e.message);
            quit ();
        }

        hold ();
    }

    public static int main (string[] args) {
        return new Ag.Application ().run (args);
    }
}
