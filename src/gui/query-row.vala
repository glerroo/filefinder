/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * This file is part of File Finder.
 * https://gitlab.gnome.org/glerro/filefinder
 *
 * query-row.vala
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

public class QueryRow : Gtk.Box {
    public signal void closed (QueryRow row);
    public signal void changed_type (QueryRow row);
    public signal void search ();

    private Gtk.ComboBoxText combo_type;
    private Gtk.Box hbox;

    private Filter _filter;
    public Filter filter {
        get {
            return _filter;
        }
    }

    public types row_type {
        get {
            return (types)combo_type.active;
        }
        set {
            combo_type.active = value;
        }
    }

    public QueryRow (types filter_type = types.LOCATION) {
        GLib.Object (orientation:Gtk.Orientation.HORIZONTAL, spacing:6);
        this.margin_top = 2;
        this.margin_bottom = 2;
        this.margin_start = 2;
        this.margin_end = 2;
        _filter = new Filter ();

        combo_type = new Gtk.ComboBoxText ();
        combo_type.tooltip_text = "Change Filter Type";
        foreach (string s in type_names) {
            combo_type.append_text (s.up ());
        }
        combo_type.active = filter_type;
        append (combo_type);
        combo_type.changed.connect (() => {
            create_type_widgets ();
            changed_type (this);
        });

        create_type_widgets ();

        Gtk.Button btn  = new Gtk.Button.from_icon_name ("window-close-symbolic");
        // Gtk.IconSize.BUTTON);
        // btn.get_style_context ().add_class (Gtk.STYLE_CLASS_ACCELERATOR);
        btn.tooltip_text = "Remove it from the search query";
        append (btn);
        btn.clicked.connect ( () => {
            closed (this);
        });

        // show_all ();
    }

    public FilterLocation location;
    public Gtk.Button chooser;
    public Gtk.Label chooser_lbl;
    private Gtk.CheckButton chk_rec;

    public FilterFiles files;
    public Gtk.Button files_btn;

    private FilterMime mime;
    private MimeButton mime_menu;

    private FilterMask mask;
    private Gtk.Entry mask_entry;
    private Gtk.CheckButton mask_case;

    private FilterModified modified;
    private Gtk.MenuButton mod_btn;

    private FilterText text;
    private Gtk.Entry text_entry;
    private Gtk.Label text_enc;
    private Gtk.CheckButton text_case;
    Gtk.Popover tpop;

    private FilterBin bin;
    private Gtk.Entry bin_entry;

    private FilterSize size;
    private Gtk.Entry size_entry;

    private void create_type_widgets () {
        int i = 0;
        // Gtk.Clipboard clipboard = Gtk.Clipboard.@get (Gdk.SELECTION_CLIPBOARD);

        if (hbox != null) hbox.destroy ();
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
        append (hbox);
        switch (combo_type.active) {
            case types.LOCATION:
                location = new FilterLocation ();
                _filter.filter_value = location;
                location.folder = Environment.get_home_dir ();

                Gtk.Box chooserBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
                chooser_lbl = new Gtk.Label (location.folder);
                Gtk.Image chooser_img = new Gtk.Image.from_icon_name ("folder-symbolic");
                chooserBox.append (chooser_img);
                chooserBox.append (chooser_lbl);
                chooser = new Gtk.Button ();
                chooser.set_hexpand (true);
                chooser.tooltip_text = location.folder;
                chooser.set_child (chooserBox);
                chooser.clicked.connect ( () => {
                    Gtk.FileDialog fdialog = new Gtk.FileDialog ();
                    // fdialog.set_modal (true);
                    fdialog.set_initial_folder (GLib.File.new_for_path (location.folder));
                    fdialog.select_folder.begin (Filefinder.window, null, (obj, res) => {
                        try {
                            GLib.File folder = fdialog.select_folder.end (res);
                            if (folder != null) {
                                location.folder = chooser.tooltip_text = folder.get_path ();
                                chooser_lbl.set_text (location.folder);
                            }
                        } catch (Error error) {
                            // stdout.printf ("Could not open file: %s\n", error.message);
                        }
                    });
                });
                hbox.append (chooser);

                chk_rec = new Gtk.CheckButton ();
                chk_rec.tooltip_text = "Recursively";
                chk_rec.active = true;
                hbox.append (chk_rec);
                chk_rec.toggled.connect (()=>{
                    location.recursive = chk_rec.active;
                });
                break;
            case types.FILES:
                files = new FilterFiles ();
                _filter.filter_value = files;

                Gtk.Box chooserBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
                chooser_lbl = new Gtk.Label ("None selected");
                Gtk.Image chooser_img = new Gtk.Image.from_icon_name ("document-open-symbolic");
                chooserBox.append (chooser_img);
                chooserBox.append (chooser_lbl);
                files_btn = new Gtk.Button ();
                files_btn.set_hexpand (true);
                files_btn.tooltip_text = "None selected";
                files_btn.set_child (chooserBox);
                files_btn.clicked.connect ( () => {
                    Gtk.FileDialog fdialog = new Gtk.FileDialog ();
                    // fdialog.set_modal (true);
                    fdialog.set_initial_folder (GLib.File.new_for_path (location.folder));
                    fdialog.open_multiple.begin (Filefinder.window, null, (obj, res) => {
                        try {
                            GLib.ListModel mfiles = fdialog.open_multiple.end (res);
                            if (mfiles != null) {
                                uint tt = 0;
                                string l = "", t = "";

                                files.clear ();
                                uint n_files = mfiles.get_n_items ();
                                for (uint n = 0; n < n_files; n++) {
                                    GLib.File file = (GLib.File) mfiles.get_item (n);
                                    files.add (file.get_path ());
                                    if (tt < 10)
                                        t += file.get_path () + "\n";
                                    tt++;
                                };
                                t += " ...\n(%u selected items)".printf (n_files);
                                files_btn.tooltip_text = t;

                                GLib.File lastFile = (GLib.File) mfiles.get_item (n_files-1);
                                l = lastFile.get_path ();
                                if (n_files > 1)
                                    l += " ... (%u selected items)".printf (n_files);
                                chooser_lbl.set_text (l);
                            }
                        } catch (Error error) {
                            // stdout.printf ("Could not open file: %s\n", error.message);
                        }
                    });
                });
                hbox.append (files_btn);
                break;
            case types.MIMETYPE:
                mime = new FilterMime ();
                _filter.filter_value = mime;
                mime.name = Filefinder.preferences.mime_type_groups[0].name;
                foreach (string s in Filefinder.preferences.mime_type_groups[0].mimes) {
                    mime.add (s);
                }

                mime_menu = new MimeButton (mime);
                hbox.append (mime_menu);
                break;
            case types.FILEMASK:
                mask = new FilterMask ();
                _filter.filter_value = mask;
                mask_entry = new Gtk.Entry ();
                hbox.append (mask_entry);
                mask_entry.changed.connect (()=>{
                    mask.mask = mask_entry.text;
                    mask_entry.tooltip_text = mask_entry.text;
                });
                mask_entry.activate.connect (()=>{search ();});
                mask_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                mask_entry.icon_press.connect ((pos) => {
                    if (pos == Gtk.EntryIconPosition.SECONDARY) {
                        mask_entry.set_text ("");
                    }
                });

                mask_case = new Gtk.CheckButton ();
                mask_case.tooltip_text = "Case sensitive";
                hbox.append (mask_case);
                mask_case.toggled.connect (()=>{
                    mask.case_sensetive = mask_case.active;
                });
                break;
            case types.SIZE:
                size = new FilterSize ();
                _filter.filter_value = size;
                Gtk.ComboBoxText size_combo = new Gtk.ComboBoxText ();
                foreach (string s in date_operators) {
                    size_combo.append_text (s);
                }
                size_combo.active = size.operator;
                size_combo.changed.connect (() => {
                    size.operator =(date_operator) size_combo.active;
                });
                hbox.append (size_combo);

                /*Gtk.Entry*/ size_entry = new Gtk.Entry();
                size_entry.set_hexpand (true);
                size_entry.text = "0";
                size_entry.width_chars = 1;
                size_entry.max_width_chars = 2;
                hbox.append (size_entry);
                size_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                size_entry.icon_press.connect ((pos) => {
                    if (pos == Gtk.EntryIconPosition.SECONDARY) {
                        size_entry.set_text ("0");
                    }
                });

                Gtk.ComboBoxText w_combo = new Gtk.ComboBoxText ();
                foreach (string s in new string[] {"B", "KiB", "MiB", "GiB"}) {
                    w_combo.append_text (s);
                }
                w_combo.active = 2;
                hbox.append (w_combo);
                w_combo.changed.connect (() => {
                    size.size = uint64.parse (size_entry.text) *
                                        size.WEIGHT[w_combo.active];
                });
                size_entry.changed.connect (()=>{
                    // size_entry.text = check_dec (size_entry.text);
                    GLib.Idle.add (check_dec);
                    size.size = uint64.parse (size_entry.text) *
                                        size.WEIGHT[w_combo.active];
                    size_entry.tooltip_text = size_entry.text;
                });
                size_entry.activate.connect (()=>{search ();});
                break;
            case types.MODIFIED:
                modified = new FilterModified ();
                _filter.filter_value = modified;
                Gtk.ComboBoxText mod_combo = new Gtk.ComboBoxText ();
                foreach (string s in date_operators) {
                    mod_combo.append_text (s);
                }
                mod_combo.active = modified.operator;
                mod_combo.changed.connect (() => {
                    modified.operator =(date_operator) mod_combo.active;
                });
                hbox.append (mod_combo);

                mod_btn = new Gtk.MenuButton ();
                // mod_btn.xalign = 0;
                mod_btn.label = "%04d-%02d-%02d".printf (modified.date.get_year(),
                                                        modified.date.get_month(),
                                                        modified.date.get_day_of_month());
                hbox.append (mod_btn);
                // mod_btn.clicked.connect (()=>{
                    Gtk.Popover pop = new Gtk.Popover ();
                    Gtk.Calendar cal = new Gtk.Calendar ();
                    cal.year = modified.date.get_year ();
                    cal.month = modified.date.get_month () - 1;
                    cal.day = modified.date.get_day_of_month ();
                    cal.day_selected.connect (()=>{
                        modified.date = new DateTime.local (cal.year, cal.month+1, cal.day, 0, 0, 0);
                        mod_btn.label = "%04d-%02d-%02d".printf (cal.year, cal.month+1, cal.day);
                    });
                    pop.set_child (cal);
                    mod_btn.set_popover (pop);
                    // pop.show_all ();
                // });
                break;
            case types.TEXT:
                text = new FilterText ();
                _filter.filter_value = text;
                // var clipboard_text = clipboard.wait_for_text ();
                // if (clipboard_text != null) text.text = clipboard_text;
                /*else*/  text.text = "";

                text_entry = new Gtk.Entry ();
                text_entry.text = text.text;
                text_entry.tooltip_text = text_entry.text;
                text_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                text_entry.icon_press.connect ((pos) => {
                    if (pos == Gtk.EntryIconPosition.SECONDARY) {
                        text_entry.set_text ("");
                    }
                });
                hbox.append (text_entry);
                text_entry.changed.connect (()=>{
                    text.text = text_entry.text;
                    text_entry.tooltip_text = text_entry.text;
                });
                text_entry.activate.connect (()=>{search ();});

                Gtk.ComboBoxText text_combo = new Gtk.ComboBoxText ();
                i = 0;
                foreach (string s in Text.encodings) {
                    text_combo.append_text (s);
                    if (s == "UTF-8")
                        text_combo.active = i;
                    i++;
                }
                // text_combo.wrap_width = 4;

                // var ebox = new Gtk.EventBox();
                // hbox.pack_start (ebox, false, false, 0);
                text_enc = new Gtk.Label ("UTF-8");
                hbox.append (text_enc);
                text.encoding = text_enc.tooltip_text = text_enc.label;
                // ebox.add (text_enc);
                tpop = new Gtk.Popover ();
                tpop.set_child (text_combo);
                // ebox.button_press_event.connect (()=>{
                //     tpop.show_all ();
                //     return true;
                // });
                text_combo.changed.connect (() => {
                    text.encoding = text_combo.get_active_text ();
                    text_enc.tooltip_text = text_enc.label = text.encoding;
                });
                

                text_case = new Gtk.CheckButton ();
                text_case.tooltip_text = "Case sensitive";
                hbox.append (text_case);
                text_case.toggled.connect (()=>{
                    text.case_sensetive = text_case.active;
                });
                break;
            case types.BINARY:
                bin = new FilterBin ();
                _filter.filter_value = bin;
                hbox.append (new Gtk.Label("0x"));
                bin_entry = new Gtk.Entry ();
                hbox.append (bin_entry);
                bin_entry.changed.connect (()=>{
                    // bin_entry.text = check_hex (bin_entry.text);
                    GLib.Idle.add (check_hex);
                    bin.bin = bin_entry.text;
                    bin_entry.tooltip_text = bin_entry.text;
                });
                // bin_entry.focus_out_event.connect (()=>{
                //     if (bin_entry.text.length % 2 == 1)
                //         bin_entry.text = "0" + bin_entry.text;
                //     return false;
                // });
                bin_entry.activate.connect (()=>{search ();});
                bin_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                bin_entry.icon_press.connect ((pos) => {
                    if (pos == Gtk.EntryIconPosition.SECONDARY) {
                        bin_entry.set_text ("");
                    }
                });
                break;
            default:
                _filter.filter_type = types.NONE;
                Gtk.Label label = new Gtk.Label ("none");
                hbox.append (label);
                break;
        }

        // hbox.show_all ();
    }

    private bool /*string*/ check_hex (/*string txt*/) {
        string txt = bin_entry.get_text ();
        string res = "";
        if (txt == null) txt = res; // return res;
        if (txt.length == 0) txt = res; // return res;
        // string symb = "0123456789ABCDEF";
        unichar c = 0;
        int index = 0;
        for (int i = 0; txt.get_next_char (ref index, out c); i++) {
            if (c.isxdigit ())
            // if (symb.index_of (c.to_string ().up ()) == -1) {
            //     return res;
            // }
                res += c.to_string ().up ();
        }
        if (res != txt) {
            bin_entry.set_text(res);
            bin_entry.set_position(-1);
        }
        return false; // res;
    }

    private bool /*string*/ check_dec (/*string txt*/) {
        string txt = size_entry.get_text ();
        string res = "";
        if (txt == null) txt = res; // return res;
        if (txt.length == 0) txt = res; // return res;
        // string symb = "0123456789";
        unichar c = 0;
        int index = 0;
        for (int i = 0; txt.get_next_char (ref index, out c); i++) {
            if (c.isdigit ())
            // if (symb.index_of (c.to_string ()) == -1) {
                // return res;
                // continue;
            // }
                res += c.to_string (); //.up ();
        }
        // if (res.length > 1)
        //     if (res.get_char ().to_string () == "0")
        //         res = res.substring (1);
        if (res != txt) {
            size_entry.set_text(res);
            size_entry.set_position(-1);
        }
        return false; // res;
    }

}
