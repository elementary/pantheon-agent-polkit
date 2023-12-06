/*
 * SPDX-License-Identifier: LGPL-2.1+
 * SPDX-FileCopyrightText: 2023 elementary, Inc. (https://elementary.io)
 */

public class Ag.Application : Gtk.Application {
    public Application () {
        Object (application_id: "io.elementary.pantheon-agent-polkit");
    }

    protected override void startup () {
        base.startup ();

        unowned var granite_settings = Granite.Settings.get_default ();
        unowned var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.notify["prefers-color-scheme"].connect (() =>
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK
        );

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK;

        var agent = new Agent ();
        int pid = Posix.getpid ();

        Polkit.Subject? subject = null;
        try {
            subject = new Polkit.UnixSession.for_process_sync (pid, null);
        } catch (Error e) {
            critical ("Unable to initiate Polkit: %s", e.message);
            quit ();
        }

        try {
            PolkitAgent.register_listener (agent, subject, null);
        } catch (Error e) {
            quit ();
        }

        hold ();
    }

    public static int main (string[] args) {
        return new Ag.Application ().run (args);
    }
}
