/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * excluded-location-list-box.vala
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
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Gianni Lerro <glerro@pm.me>
 */

public class NewItem : GLib.Object {}

public class NewItemModel : GLib.Object, GLib.ListModel  {
    private NewItem _item;

    public NewItemModel () {
        _item = new NewItem ();
    }

    public GLib.Object? get_item (uint position) {
         return _item;
    }

    public Type get_item_type () {
         return typeof (NewItem);
    }

    public uint get_n_items () {
         return 1;
    }
}

public class ExcludedLocationListModel : GLib.Object, GLib.ListModel {
    private GLib.Settings settings;
    private Gtk.StringList _items;

    public ExcludedLocationListModel () {
        this.settings = new GLib.Settings ("org.konkor.filefinder");
        this._items = new Gtk.StringList (this.settings.get_strv("excluded-location"));

        this.settings.changed.connect ( (key) => {
            if (key == "excluded-location") {
                uint removed = this._items.get_n_items ();
                string[] _names = this.settings.get_strv("excluded-location");
                this._items.splice(0, removed, _names);
                this.items_changed(0, removed, _names.length);
            }
        });
    }

    private string[] get_strings (Gtk.StringList items) {
        string[]? strings = {};

        for (uint i = 0; i < items.get_n_items (); i++) {
            strings += items.get_string (i);
        }

        return strings;
    }

    public void append (string name) {

        var pos = this._items.get_n_items();
        this._items.append (name);
        this.items_changed (pos, 0, 1);

        this.settings.set_strv("excluded-location", get_strings(this._items));
        return;
    }

    public void remove (string name) {
        var pos = -1;

        for (int i = 0; i < this._items.get_n_items (); i++) {
            if ((string) this._items.get_string (i) == name)
                pos = i;
        }

        if (pos < 0)
            return;

        this._items.remove (pos);
        this.items_changed (pos, 1, 0);

        this.settings.set_strv("excluded-location", get_strings(this._items));
        return;
    }

    public GLib.Object? get_item (uint position) {
         return _items.get_item (position);
    }

    public Type get_item_type () {
         return typeof (Gtk.StringObject);
    }

    public uint get_n_items () {
         return _items.get_n_items();
    }
}

public class ExcludedLocationListRow : Adw.PreferencesRow {

    public ExcludedLocationListRow (string name) {

        this.name = name;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        box.set_margin_top (6);
        box.set_margin_bottom (6);
        box.set_margin_start (6);
        box.set_margin_end (6);

        Gtk.Label label = new Gtk.Label (name);
        label.set_hexpand (true);
        label.set_xalign (0);
        label.set_max_width_chars (25);
        label.set_ellipsize (Pango.EllipsizeMode.END);

        box.append (label);

        Gtk.Button button = new Gtk.Button ();
        button.set_action_name ("excluded-location.remove");
        button.set_icon_name ("edit-delete-symbolic");
        button.set_has_frame (false);
        box.append (button);

        this.set_child (box);

        this.bind_property("name", button, "action-target",
            GLib.BindingFlags.SYNC_CREATE,
            (bind, source, ref target) => {
                target.set_variant (new GLib.Variant("s", (string) source));
                return true;
            }
        );
    }
}

public class NewItemRow : Adw.PreferencesRow {
    public NewItemRow() {
        this.set_action_name ("excluded-location.add");

        Gtk.Image imageAdd = new Gtk.Image.from_icon_name ("list-add-symbolic");
        imageAdd.set_pixel_size (16);
        imageAdd.set_margin_top (12);
        imageAdd.set_margin_bottom (12);
        imageAdd.set_margin_start (12);
        imageAdd.set_margin_end (12);

        this.set_child (imageAdd);
    }
}

public class ExcludedLocationListBox : Gtk.Widget {
	private Gtk.ListBox list_box;

	static construct {
		set_layout_manager_type (typeof (Gtk.BinLayout));
	}

    public ExcludedLocationListBox () {
        list_box = new Gtk.ListBox ();
        list_box.set_parent (this);

        list_box.set_selection_mode (Gtk.SelectionMode.NONE);
        list_box.set_css_classes ({"boxed-list"});

        ExcludedLocationListModel el_listmodel = new ExcludedLocationListModel ();

        GLib.ListStore store = new GLib.ListStore (typeof (GLib.ListModel));
        Gtk.FlattenListModel list_model = new Gtk.FlattenListModel (store);
        store.append (el_listmodel);
        store.append (new NewItemModel());

        list_box.bind_model(list_model, (item) => {
            var string_object = (Gtk.StringObject) item;

            if (item.get_type () == typeof (NewItem))
                return new NewItemRow ();
            else
                return new ExcludedLocationListRow (string_object.string);
        });

        GLib.SimpleActionGroup actionGroup = new GLib.SimpleActionGroup();

        GLib.SimpleAction action1 = new GLib.SimpleAction ("add", null);
        action1.activate.connect(() => {
            Gtk.FileDialog fdialog = new Gtk.FileDialog ();
            fdialog.set_modal (true);
            fdialog.select_folder.begin (null, null, (obj, res) => {
                try {
                    GLib.File folder = fdialog.select_folder.end (res);
                    string filename = folder.get_path ();

                    el_listmodel.append (filename);
                } catch (Error error) {
                    // stdout.printf ("Could not open file: %s\n", error.message);
                }
            });
        });
        actionGroup.add_action (action1);

        GLib.SimpleAction action2 = new GLib.SimpleAction ("remove", new GLib.VariantType("s"));
        action2.activate.connect((param) => {
            el_listmodel.remove(param.get_string ());
        });
        actionGroup.add_action (action2);

        list_box.insert_action_group ("excluded-location", actionGroup);
    }
}

