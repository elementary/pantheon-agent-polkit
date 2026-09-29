/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public sealed class Ag.GcrPrompt : Gcr.Prompt, Object {
    public string caller_window { owned get; set construct; }
    public string cancel_label { owned get; set construct; }
    public bool choice_chosen { get; set; }
    public string choice_label { owned get; set construct; }
    public string continue_label { owned get; set construct; }
    public string description { owned get; set construct; }
    public string message { owned get; set construct; }
    public bool password_new { get; set; }
    public int password_strength { get; }
    public string title { owned get; set construct; }
    public string warning { owned get; set construct; }

    private bool user_responded = false;
    private GcrConfirmDialog? confirm_dialog;
    private Gcr.PromptReply confirm_result;
    private GcrPasswordDialog? password_dialog;
    private string? responded_password;

    public async Gcr.PromptReply confirm_async (GLib.Cancellable? cancellable) throws GLib.Error {
        confirm_dialog = new GcrConfirmDialog (this);
        confirm_dialog.response.connect ((confirm_dialog, response) => {
            if (user_responded) {
                return;
            }

            switch (response) {
                case Gtk.ResponseType.CANCEL:
                case Gtk.ResponseType.CLOSE:
                case Gtk.ResponseType.DELETE_EVENT:
                    confirm_result = CANCEL;
                    break;
                default:
                    confirm_result = CONTINUE;
                    break;
            }

            user_responded = true;
            confirm_async.callback ();
        });
        confirm_dialog.present ();

        yield;

        return confirm_result;
    }

    public async unowned string password_async (GLib.Cancellable? cancellable) throws GLib.Error {
        password_dialog = new GcrPasswordDialog (this);
        password_dialog.response.connect ((password_dialog, response) => {
            if (user_responded) {
                return;
            }

            switch (response) {
                case Gtk.ResponseType.CANCEL:
                case Gtk.ResponseType.CLOSE:
                case Gtk.ResponseType.DELETE_EVENT:
                    responded_password = "";
                    break;
                default:
                    responded_password = ((GcrPasswordDialog) password_dialog).password;
                    break;
            }

            user_responded = true;
            password_async.callback ();
        });
        password_dialog.present ();

        yield;

        return responded_password;
    }

    public override void prompt_close () {
        password_dialog?.close ();
        confirm_dialog?.close ();
    }
}
