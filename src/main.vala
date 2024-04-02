/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * main.vala
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

public class Main : GLib.Object {
    private static bool version = false;
    private static bool license = false;
    private static bool debug = false;
    [CCode (array_length = false, array_null_terminated = true)]
	private static string[]? directories = null;
    // private static string? directory = null;

    private const GLib.OptionEntry[] options = {
        { "version", 'v', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref version, "Display version number", null },
        { "license", 'l', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref license, "Display license", null },
        { "debug", 'd', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref debug, "Print debug messages", null },
        { GLib.OPTION_REMAINING, '\0', 0, GLib.OptionArg.FILENAME_ARRAY, ref directories, "Path file to search", "[PATH]" },
        { null }
    };

    static int main (string[] args) {
        Filefinder.debugging = false;

        try {
            var opt_context = new GLib.OptionContext (null);
            opt_context.set_help_enabled (true);
            opt_context.set_summary ("File Finder, a lightweight find tool");
            opt_context.set_description ("For more help on how to use File Finder, head to https://gitlab.gnome.org/glerro/filefinder");
            opt_context.add_main_entries (options, null);
            opt_context.parse (ref args);
        } catch (OptionError e) {
            GLib.printerr ("Error: %s\n", e.message);
            GLib.printerr ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 1;
        }

        if (version) {
            GLib.print ("%s\n", Text.app_name + " - " + Text.app_version);
            return 0;
        }

        if (license) {
            GLib.print ("%s\n", "\n" + Text.app_info + "\n\n" + Text.app_license + "\n");
            return 0;
        }

        if (debug) {
            Filefinder.debugging = true;
        }

       var app = new Filefinder (/*directories*/);

       return app.run (directories);
    }
}

