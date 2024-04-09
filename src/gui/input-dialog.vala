/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * input-dialog.vala
 *
 * Copyright (c) 2024 Gianni Lerro {glerro} ~ <glerro@pm.me>
 *
 * File Finder is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * File Finder is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with File Finder. If not, see <https://www.gnu.org/licenses/>.
 *
 * *****************************************************************************
 * Original Author: 2016 Kostiantyn Korienkov <kkorienkov [at] gmail.com>
 * *****************************************************************************
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Gianni Lerro <glerro@pm.me>
 */

public class InputDialog : Gtk.Dialog {

    public Gtk.Label label;
    public Gtk.Entry entry;

    public InputDialog (Gtk.Window? w = null) {
        set_transient_for (w);
        title = Text.app_name;
        add_button ("_Cancel", Gtk.ResponseType.CANCEL);
        add_button ("_OK", Gtk.ResponseType.ACCEPT);
        set_default_size (512, 140);
        Gtk.Box content = get_content_area () as Gtk.Box;
        content.spacing = 6;

        label = new Gtk.Label (null);
        label.xalign = 0;
        content.append (label);

        entry = new Gtk.Entry ();
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear");
        entry.icon_press.connect ((pos) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                entry.set_text ("");
            }
        });
        Gtk.EventControllerKey controller = new Gtk.EventControllerKey ();
        controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE)   ;
        entry.add_controller (controller);
        controller.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == Gdk.Key.Return || keyval == Gdk.Key.KP_Enter) {
                response (Gtk.ResponseType.ACCEPT);
                return true;
            }
            return false;
        });
        content.append (entry);
    }
}

