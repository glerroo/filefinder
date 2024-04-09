/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * page-plugin.vala
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

public class PagePlugin : Adw.PreferencesPage {

    public PagePlugin () {
        this.set_title ("Extensions");

        this.settings = new GLib.Settings ("org.konkor.filefinder");

        build ();
    }

    private int selection = -1;
    private GLib.Settings settings;
    private Gtk.TreeView view;
    private Gtk.ListStore store;

    private Gtk.CheckButton cb_toolbar;
    private Gtk.CheckButton cb_tgroups;
    private Gtk.CheckButton cb_thotkey;
    private Gtk.Box tbox;

    private void build () {
        Adw.PreferencesGroup group_c = new Adw.PreferencesGroup ();
        this.add (group_c);

        Adw.SwitchRow cb_toolbar = new Adw.SwitchRow ();
        cb_toolbar.set_title ("Show plugin toolbar");
        cb_toolbar.set_active (false);
        group_c.add (cb_toolbar);
        this.settings.bind ("show-toolbar", cb_toolbar, "active", GLib.SettingsBindFlags.DEFAULT);

        Adw.SwitchRow cb_tgroups = new Adw.SwitchRow ();
        cb_tgroups.set_title ("Enable groups of the extensions");
        cb_tgroups.set_active (true);
        group_c.add (cb_tgroups);
        this.settings.bind ("toolbar-groups", cb_tgroups, "active", GLib.SettingsBindFlags.DEFAULT);

        Adw.SwitchRow cb_thotkey = new Adw.SwitchRow ();
        cb_thotkey.set_title ("Show keyboard shotcuts");
        cb_thotkey.set_active (true);
        group_c.add (cb_thotkey);
        this.settings.bind ("toolbar-shortcuts", cb_thotkey, "active", GLib.SettingsBindFlags.DEFAULT);

        cb_toolbar.activated.connect (()=>{
            // if (Filefinder.preferences == null) return;
            // Filefinder.preferences.show_toolbar = cb_toolbar.active;
            // tbox.sensitive = cb_toolbar.active;
            // Filefinder.preferences.is_changed = true;
        });
        cb_tgroups.activated.connect (()=>{
            // if (Filefinder.preferences == null) return;
            // Filefinder.preferences.toolbar_groups = cb_tgroups.active;
            // Filefinder.preferences.is_changed = true;
        });
        cb_thotkey.activated.connect (()=>{
            // if (Filefinder.preferences == null) return;
            // Filefinder.preferences.toolbar_shotcuts = cb_thotkey.active;
            // Filefinder.preferences.is_changed = true;
        });

        Adw.PreferencesGroup group_d = new Adw.PreferencesGroup ();
        group_d.set_title ("Extension Manager");
        this.add (group_d);

        Gtk.Box hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        group_d.add (hbox);

        Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow ();
        // scroll.shadow_type = Gtk.ShadowType.OUT;
        hbox.append (scroll);

        view = new Gtk.TreeView ();
        view.set_hexpand (true);
        view.set_vexpand (true);
        store = new Gtk.ListStore (4, typeof (bool), typeof (string), typeof (string), typeof (string));
        view.set_model (store);
        Gtk.CellRendererToggle toggle = new Gtk.CellRendererToggle ();
        toggle.toggled.connect ((toggle, path) => {
            Gtk.TreePath tree_path = new Gtk.TreePath.from_string (path);
            Gtk.TreeIter iter;
            int i = tree_path.get_indices ()[0];
            bool active = !toggle.active;
            store.get_iter (out iter, tree_path);
            store.set (iter, 0, !toggle.active);
            try {
                foreach (Plugin f in Filefinder.preferences.plugins)
                    f.default_action = false;
                Plugin p = (Plugin) Filefinder.preferences.plugins.nth_data (i);
                p.default_action = !toggle.active;
                if (active) {
                    Filefinder.preferences.default_plugin = Filename.to_uri(p.uri);
                } else {
                    Filefinder.preferences.default_plugin = "";
                }
                reload ();
                Filefinder.preferences.is_changed = true;
            } catch (Error e) {
                Debug.error ("default_plugin", e.message);
            }
        });
        view.insert_column_with_attributes (-1, "Default", toggle, "active", 0, null);
        view.insert_column_with_attributes (-1, "Name", new Gtk.CellRendererText (), "text", 1, null);
        view.insert_column_with_attributes (-1, "Hotkey", new Gtk.CellRendererText (), "text", 2, null);
        view.insert_column_with_attributes (-1, "Description", new Gtk.CellRendererText (), "text", 3, null);
        view.get_column (3).visible = false;
        view.set_tooltip_column (3);
        scroll.set_child (view);
        view.get_selection ().changed.connect (on_selection);

        Gtk.Box vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        hbox.append (vbox);

        Gtk.Button button = new Gtk.Button.with_label ("New");
        button.tooltip_text = "Add New Extension From Template";
        button.clicked.connect (()=>{
            var d = new InputDialog (Filefinder.window);
            d.label.label = "Input a new extension file name";
            d.entry.text = "my_extension";
            d.set_modal (true);
            d.present ();
            d.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    string pname = d.entry.text.down().strip ().replace (" ", "_");
                    pname = pname.replace ("/", "_");
                    pname = pname.replace ("\"", "");
                    pname = pname.replace ("?", "");
                    pname = pname.replace (":", "_");
                    pname = pname.replace ("\\", "_");
                    if (pname.length > 0) {
                        File? plug = Filefinder.preferences.create_plug (pname);
                        if (plug != null) {
                            List<File> flist = new List<File> ();
                            flist.append (plug);
                            AppInfo app = GLib.AppInfo.get_default_for_type ("application/x-shellscript", false);
                            if (app != null) {
                                try {
                                    app.launch (flist, null);
                                    reload ();
                                } catch (Error e) {
                                    var dlg = new Gtk.MessageDialog (Filefinder.window, 0,
                                        Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE, "Failed to launch: %s",
                                        e.message);
                                    dlg.present ();
                                    dlg.destroy ();
                                }
                            }
                        }
                    }
                }
                d.destroy ();
            });
        });
        vbox.append (button);

        button = new Gtk.Button.with_label ("Edit");
        button.tooltip_text = "Edit Selected Extension";
        button.clicked.connect (()=>{
            if (selection == -1) return;
            List<File> flist = new List<File> ();
            flist.append (File.new_for_path (Filefinder.preferences.plugins.nth_data (selection).uri));
            AppInfo app = GLib.AppInfo.get_default_for_type ("application/x-shellscript", false);
            if (app != null) {
                try {
                    app.launch (flist, null);
                    reload ();
                } catch (Error e) {
                    var dlg = new Gtk.MessageDialog (Filefinder.window, 0,
                        Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE, "Failed to launch: %s",
                        e.message);
                    dlg.present ();
                    dlg.destroy ();
                }
            }
        });
        vbox.append (button);

        vbox.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        button = new Gtk.Button.with_label ("Install");
        button.tooltip_text = "Install Extensions From Drive";
        button.clicked.connect (()=>{
            Gtk.FileDialog c = new Gtk.FileDialog ();
            c.set_title ("Select Extensions");
            Gtk.FileFilter filter_text = new Gtk.FileFilter ();
            filter_text.set_filter_name ("Shell Script");
            filter_text.add_mime_type ("application/x-shellscript");
            c.set_default_filter (filter_text);
            // c.set_initial_folder (GLib.File.new_for_path (location.folder));
            c.open_multiple.begin (Filefinder.window, null, (obj, res) => {
                try {
                    GLib.ListModel mfiles = c.open_multiple.end (res);
                    if (mfiles != null) {
                        GLib.SList<string> filenames = new GLib.SList<string> ();
                        uint n_files = mfiles.get_n_items ();
                        for (uint n = 0; n < n_files; n++) {
                            GLib.File file = (GLib.File) mfiles.get_item (n);
                            filenames.append (file.get_path ());
                        };
                        install (filenames);
                        reload ();
                    }
                } catch (Error error) {
                    // stdout.printf ("Could not open file: %s\n", error.message);
                }
            });
        });
        vbox.append (button);

        button = new Gtk.Button.with_label ("Delete");
        button.tooltip_text = "Delete Selected Extensions";
        button.clicked.connect (()=>{
            if (selection == -1) return;
            // ResultsView.delete_file (File.new_for_path (Filefinder.preferences.plugins.nth_data (selection).uri));
            reload ();
        });
        vbox.append (button);
    }

    public void reload () {
print ("Reload .......\n");
        Gtk.TreeIter it;
        if (Filefinder.preferences == null) return;
        Filefinder.preferences.load_plugs ();
print ("N plugins: %u\n", Filefinder.preferences.plugins.length ());
        store.clear ();
        foreach (Plugin p in Filefinder.preferences.plugins) {
            store.append (out it);
            store.set (it,
                       0, p.default_action,
                       1, p.label,
                       2, p.hotkey,
                       3, p.description, -1);
print(p.label+"\n");
        }
        // cb_toolbar.active = Filefinder.preferences.show_toolbar;
        // cb_tgroups.active = Filefinder.preferences.toolbar_groups;
        // cb_thotkey.active = Filefinder.preferences.toolbar_shotcuts;
    }

    private void on_selection () {
        uint count = view.get_selection ().get_selected_rows (null).length();
        if (count == 0) {
            selection = -1;
            return;
        }
        selection = view.get_selection ().get_selected_rows (null).nth_data(0).get_indices()[0];
    }

    private bool skip_all;
    private bool replace_all;

    // TODO: check i realy work all
    private void install (SList<string> list) {
        File f1, f2;
        string path = Path.build_filename (Environment.get_user_data_dir (),
                                            "filefinder", "extensions");
        f2 = File.new_for_path (path);
        if (!f2.query_exists ())
            DirUtils.create_with_parents (path, 0744);
        replace_all = skip_all = false;
        foreach (string s in list) {
            f1 = File.new_for_path (s);
            f2 = File.new_for_path (Path.build_filename (path, f1.get_basename()));
            if (f2.query_exists () && !replace_all) {
                if (skip_all) continue;
                var dlg = new Gtk.MessageDialog (Filefinder.window, 0,
                        Gtk.MessageType.WARNING, Gtk.ButtonsType.NONE,
                        "The destination file is exist.\nDo you want replace it?\n\n%s",
                        f2.get_path());
                dlg.add_buttons ("Skip All", Gtk.ResponseType.CANCEL + 100,
                                 "Replace All", Gtk.ResponseType.ACCEPT + 100,
                                 "Skip", Gtk.ResponseType.CANCEL,
                                 "Replace", Gtk.ResponseType.ACCEPT);
                dlg.present ();
                dlg.response.connect ((response_id) => {
                    switch (response_id) {
                        case Gtk.ResponseType.CANCEL:
                            break;
                        case Gtk.ResponseType.ACCEPT + 100:
                            replace_all = true;
                            break;
                        case Gtk.ResponseType.CANCEL + 100:
                            skip_all = true;
                            break;
                    }
                    dlg.destroy ();
                });
            }
            if (f2.query_exists ()) {
                // if (!ResultsView.delete_file (f2)) {
                //     continue;
                // }
            }
            try {
                f1.copy (f2, 0, null, null);
            } catch (Error e) {
                Debug.error ("install_plugs", e.message);
            }
        }
    }
}

