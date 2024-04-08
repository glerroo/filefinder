/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * filefinder.vala
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

public class Filefinder : Adw.Application
{
    public static bool debugging;
    private Settings settings;
    public static FileFinderWindow? window = null;
    public static Preferences preferences;
    // public static Service service;
    // public static Filefinder self;
    // public static List<string> uris;

    public Filefinder (/*string[] args*/) {
        GLib.Object (application_id: "org.konkor.filefinder",
            flags: ApplicationFlags.HANDLES_OPEN);

            // set_resource_base_path ("/org/konkor/filefider");
    //  uris = new List<string>();
    //  int i, count = args.length;
    //  for (i = 1; i < count; i++) {
    //      switch (args[i]) {
    //          case "--help":
    //          case "--version":
    //          case "--license":
    //          case "--debug":
    //              break;
    //          default:
    //              uris have to process in the open handler
    //          break;
    //      }
    //  }
    //     self = this;
    }

    construct {
        // this.settings = new GLib.Settings ("org.konkor.filefinder");

        GLib.ActionEntry[] action_entries = {
            {"about", on_about_action},
            {"preferences", on_preferences_action},
            {"quit", this.quit},
            // {"add_location", add_location_cb},
            // {"toggle_paned", toggle_paned_cb}
        };
        this.add_action_entries (action_entries, this);
        this.set_accels_for_action ("app.quit", {"<primary>q"});
    }

    private const GLib.ActionEntry[] action_entries = {
    };

    protected override void startup () {
        base.startup ();

        this.settings = new GLib.Settings ("org.konkor.filefinder");

        // this.settings.set_boolean ("cb-single", true);
        // settings.apply ();
        // GLib.Menu section = new GLib.Menu ();
        // section.append_item (new GLib.MenuItem ("Preferences", "app.preferences"));
        // section.append_item (new GLib.MenuItem ("About", "app.about"));
        // section.append_item (new GLib.MenuItem ("Quit", "app.quit"));
        // GLib.Menu menu = new GLib.Menu ();
        // menu.append_section (null, section);
        // this.set_app_menu ((GLib.MenuModel) menu);

        // set_accels_for_action ("app.add_location", {"Insert"});
        // set_accels_for_action ("app.toggle_paned", {"<Ctrl>n"});

        // Environment.set_application_name (Text.app_name);

        preferences = new Preferences ();
        // preferences.transient_for = this.active_window;

        // service = new Service ();

        // window = new FileFinderWindow (this);
        // window.show_all ();
        // window.post_init ();
        // window.go_clicked.connect ((q)=>{
        //  if (window.get_window () == null) return;
        //  Debug.info ("loc count", "%u".printf (q.locations.length ()));
        //  Debug.info ("file count", "%u".printf (q.files.length ()));
        //  Debug.info ("mask count", "%u".printf (q.masks.length ()));
        //  Debug.info ("mime count", "%u".printf (q.mimes.length ()));
        //  Debug.info ("mod count", "%u".printf (q.modifieds.length ()));
        //  Debug.info ("text count", "%u".printf (q.texts.length ()));
        //  Debug.info ("bin count", "%u".printf (q.bins.length ()));
        //  Debug.info ("size count", "%u".printf (q.sizes.length ()));
        //  service = new Service ();
        //  window.result_view.connect_model ();
        //  service.finished_search.connect (()=>{
        //      window.show_results ();
        //  });
        //  service.row_changed.connect(()=>{window.set_subtitle ();});
        //  window.canceled.connect (()=>{
        //      service.cancel ();
        //  });
        //  service.start (q);
        // });
        //window.add_locations (uris);
        // open.connect ((files) => {
        //  foreach (File f in files) {
        //      if (f.query_exists ()) uris.append (f.get_path());
        //  }
        //  if ((window.get_window () != null) && (uris.length() > 0))
        //      window.add_locations (uris);
        // });
        // preferences.load_plugs ();
        // window.enable_toolbar ();
    }


    protected override void activate () {
        base.activate ();
        window = (FileFinderWindow) this.active_window;
        if (window == null) {
            window = new FileFinderWindow (this);
        }
        window.present ();
    }

    // private void quit_cb () {
    //     exit ();
    // }

    // public static void exit () {
    //     window.destroy ();
    // }

    // private void preferences_cb () {
    //     preferences.show_window ();
    // }

    // private void add_location_cb () {
    //     window.add_filter ();
    // }

    // private void toggle_paned_cb () {
    //     if (window == null) return;
    //     window.toggle_paned ();
    // }

    // protected override void shutdown() {
    //     preferences.save ();
    //     base.shutdown();
    // }

    // private void about_cb () {
    //     about ();
    // }

    private void on_about_action () {
        string[] developers = { "Gianni Lerro <glerro.pm.me>",
            "Kostiantyn Korienkov <kkorienkov [at] gmail.com>" };
        var about = new Adw.AboutWindow () {
            transient_for = this.active_window,
            application_name = Text.app_name,
            application_icon = "filefinder",
            developer_name = "Gianni Lerro",
            version = Text.app_version,
            developers = developers,
            license_type = Gtk.License.GPL_3_0,
            copyright = "Copyright © 2016 Kostiantyn Korienkov\nCopyright © 2024 Gianni Lerro",
            website = "https://gitlab.gnome.org/glerro/filefinder",
            issue_url = "https://gitlab.gnome.org/glerro/filefinder/issues",
            comments = "File Finder is lightweight find tool",
        };

        about.present ();
    }

    private void on_preferences_action () {
        preferences.present (this.active_window);
    }

    // public static bool exist (string filepath) {
    //     GLib.File file = File.new_for_path (filepath.strip ());
    //     return file.query_exists ();
    // }

    // public static GenericSet<File>   get_excluded_locations () {
    //     var excluded_locations = new GenericSet<File> (File.hash, File.equal);
    //     excluded_locations.add (File.new_for_path ("/dev"));
    //     excluded_locations.add (File.new_for_path ("/proc"));
    //     excluded_locations.add (File.new_for_path ("/sys"));
    //     excluded_locations.add (File.new_for_path ("/selinux"));

    //     var home = File.new_for_path (Environment.get_home_dir ());
    //     excluded_locations.add (home.get_child (".gvfs"));

    //     /*var root = File.new_for_path ("/");
    //     foreach (var uri in prefs_settings.get_value ("excluded-uris")) {
    //         var file = File.new_for_uri ((string) uri);
    //         if (!file.equal (root)) {
    //             excluded_locations.add (file);
    //         }
    //     }*/

    //     return excluded_locations;
    // }
}

