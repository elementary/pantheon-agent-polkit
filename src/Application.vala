/*
 * SPDX-License-Identifier: LGPL-2.1-or-later
 * SPDX-FileCopyrightText: 2023 elementary, Inc. (https://elementary.io)
 */

public class Ag.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "io.elementary.PolkitAgent",
            flags: GLib.ApplicationFlags.IS_SERVICE,
            register_session: true
        );
    }

    protected override void startup () {
        base.startup ();

        Granite.init ();

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
