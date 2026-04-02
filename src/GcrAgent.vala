/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public sealed class Ag.GcrAgent : Gcr.SystemPrompter {
    construct {
        try {
            var connection = Bus.get_sync (SESSION);
            register (connection);

            Bus.own_name_on_connection (connection, "org.gnome.keyring.SystemPrompter", ALLOW_REPLACEMENT);
        } catch (Error e) {
            critical (e.message);
        }

        new_prompt.connect (on_new_prompt);
    }

    private Gcr.Prompt on_new_prompt () {
        return new GcrPrompt ();
    }
}
