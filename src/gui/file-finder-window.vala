/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * file-finder-window.vala
 * Copyright (C) 2016 see AUTHORS <>
 *
 * filefinder is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * filefinder is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Gtk;

public class FileFinderWindow : Gtk.ApplicationWindow {
	public signal void go_clicked (Query q);
	public signal void canceled ();

	public FileFinderWindow (Gtk.Application app) {
		GLib.Object (application: app);
		build ();
		initialize ();
	}

	private Gtk.Box vbox1;
	private Gtk.InfoBar infoBar;
	private Gtk.Box infoBox;
	private Gtk.HeaderBar hb;
	private Gtk.ToggleButton button_go;
	private Gtk.Button button_plus;
	private Gtk.Paned paned;
	private Gtk.ScrolledWindow scrolledwindow1;
	private Gtk.AccelGroup accel_group;

	private Gtk.Box empty_box;

	private QueryEditor editor;
	public ResultsView result_view;

	protected void build () {
		set_position (Gtk.WindowPosition.CENTER);
		//set_border_width (4);

		accel_group = new AccelGroup ();
		this.add_accel_group (accel_group);

		hb = new Gtk.HeaderBar ();
		//hb.has_subtitle = false;
		hb.title = Text.app_name;
		hb.set_show_close_button (true);
		set_titlebar (hb);

		button_go = new Gtk.ToggleButton ( );
		button_go.use_underline = true;
		button_go.can_default = true;
		this.set_default (button_go);
		button_go.label = "Search";
		button_go.tooltip_text = "Start Search <Control+Return>";
		button_go.get_style_context ().add_class ("suggested-action");
		hb.pack_end (button_go);
		button_go.add_accelerator ("clicked", accel_group,
									Gdk.keyval_from_name("Return"),
									Gdk.ModifierType.CONTROL_MASK,
									AccelFlags.VISIBLE);

		button_plus = new Button.from_icon_name ("list-add-symbolic", IconSize.BUTTON);
		button_plus.always_show_image = true;
		button_plus.use_underline = true;
		button_plus.xalign = 0;
		//button_plus.label = "Add Filter";
		button_plus.tooltip_text = "Add Filter <Insert>";
		hb.pack_start (button_plus);

		vbox1 = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		add (vbox1);

		infoBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		vbox1.pack_start (infoBox, false, true, 0);

		empty_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 40);
		empty_box.margin = 80;
		vbox1.pack_start (empty_box, true, true, 0);

		Gtk.Image image = new Gtk.Image.from_icon_name ("folder-documents-symbolic", Gtk.IconSize.DIALOG);
		empty_box.add (image);
		empty_box.add (new Label("\t\t\t   No search results.\n"+Text.first_run));

		paned = new Gtk.Paned (Filefinder.preferences.split_orientation);
		paned.events |= Gdk.EventMask.VISIBILITY_NOTIFY_MASK;
		paned.can_focus = true;
		if (Filefinder.preferences.split_orientation == Gtk.Orientation.VERTICAL)
			paned.position = 1;// paned.min_position;
		else
			paned.position = 480;
		vbox1.add (paned);

		scrolledwindow1 = new Gtk.ScrolledWindow (null, null);
		scrolledwindow1.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scrolledwindow1.shadow_type = Gtk.ShadowType.NONE;
		scrolledwindow1.get_style_context ().add_class ("search-bar");
		paned.pack1 (scrolledwindow1, false, true);

		editor = new QueryEditor ();
		editor.expand = true;
		scrolledwindow1.add (editor);
		editor.changed_rows.connect (()=>{check_paned_position ();});

		//vbox1 = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		//paned.pack2 (vbox1, true, false);
		//vbox1.pack_start (empty_box, true, true, 0);
		
		Gtk.ScrolledWindow scrolledwindow = new Gtk.ScrolledWindow (null, null);
		scrolledwindow.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scrolledwindow.shadow_type = Gtk.ShadowType.OUT;
		paned.pack2 (scrolledwindow, true, false);
		//vbox1.pack_start (scrolledwindow, true, true, 0);

		result_view = new ResultsView ();
		scrolledwindow.add (result_view);

		set_default_size (800, 512);
		if (Filefinder.preferences.first_run) {
			show_info (Text.first_run);
			Filefinder.preferences.first_run = false;
		}
	}

	private void initialize () {
		button_go.clicked.connect (on_go_clicked);
		button_plus.clicked.connect ( ()=>{
			Gtk.Popover pop = new Gtk.Popover (button_plus);
			vbox1 = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			pop.add (vbox1);
			for (int i = 0; i < types.NONE; i++) {
				var b = new ButtonType ((types) i, type_names[i]);
				b.clicked.connect ((o)=>{
					add_filter ((o as ButtonType).filter_type);
				});
				vbox1.add (b);
			}
			pop.show_all ();
		});
		paned.visibility_notify_event.connect (()=>{
			empty_box.visible = !paned.visible;
			return false;
		});
		result_view.changed_selection.connect (()=>{set_subtitle ();});
	}

	public void post_init () {
		paned.visible = false;
	}

	private void check_paned_position () {
		int h1, h2 , count;
		if (Filefinder.preferences.split_orientation == Gtk.Orientation.VERTICAL) {
			count = (int) editor.rows.length ();
			if (count == 0) {
				paned.position = 1;
			} else if (count == 1) {
				scrolledwindow1.get_preferred_height (out h1, out h2);
				paned.position = h1;
			} else {
				(editor.rows.nth_data(0) as QueryRow).get_preferred_height (out h1, out h2);
				if (editor.rows.length() * h1 < 200) paned.position = (int) editor.rows.length() * h1 + 4;
			}
		}
	}

	public void add_filter (types filter_type = types.LOCATION) {
		paned.visible = true;
		editor.add_filter (filter_type);
	}

	public void add_locations (List<string> uris) {
		File file;
		foreach (string s in uris) {
			file = File.new_for_path (s);
			paned.visible = true;
			if (file.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY) {
				editor.add_folder (s);
			} else {
				editor.add_file (s);
			}
		}
		//check_paned_position ();
	}

	private void on_go_clicked () {
		if (button_go.active) {
			button_go.label = "Stop";
			go_clicked (query);
			//result_view.disconnect_model ();
		} else {
			button_go.label = "Search";
			canceled ();
			//result_view.connect_model ();
		}
	}

	public void set_subtitle () {
		if (Filefinder.service == null) {
			hb.subtitle = "";
			return;
		}
		if (Filefinder.service.results_all == null) {
			hb.subtitle = "";
			return;
		}
		int n = result_view.model.iter_n_children (null);
		if (n > 0)
			if (result_view.results_selection.position == 0)
				hb.subtitle = "(%d items in %s)".printf (n,
					result_view.get_bin_size (Filefinder.service.results_all.size));
			else
				hb.subtitle = "(selected %jd items in %s of the %d items in %s)".printf (
					result_view.results_selection.position,
					result_view.get_bin_size (result_view.results_selection.size),
					n, result_view.get_bin_size (Filefinder.service.results_all.size));
		else
			hb.subtitle = "(No items found)";
		//if ((n%1000) == 0) while (Gtk.events_pending ()) Gtk.main_iteration ();
	}

	public void split_orientation (Gtk.Orientation orientation) {
		paned.orientation = orientation;
	}

	public void set_column_visiblity (int column, bool visible) {
		result_view.get_column (column).visible = visible;
	}

	private uint info_timeout_id = 0;
	public int show_message (string text, MessageType type = MessageType.INFO) {
		if (infoBar != null) infoBar.destroy ();
		if (type == Gtk.MessageType.QUESTION) {
			infoBar = new InfoBar.with_buttons ("gtk-yes", Gtk.ResponseType.YES,
												"gtk-cancel", Gtk.ResponseType.CANCEL);
		} else {
			infoBar = new InfoBar.with_buttons ("gtk-close", Gtk.ResponseType.CLOSE);
			infoBar.set_default_response (Gtk.ResponseType.OK);
		}
		infoBar.set_message_type (type);
		Gtk.Container content = infoBar.get_content_area ();
		switch (type) {
			case Gtk.MessageType.QUESTION:
				content.add (new Gtk.Image.from_icon_name ("gtk-dialog-question", Gtk.IconSize.DIALOG));
				break;
			case Gtk.MessageType.INFO:
				content.add (new Gtk.Image.from_icon_name ("gtk-dialog-info", Gtk.IconSize.DIALOG));
				break;
			case Gtk.MessageType.ERROR:
				content.add (new Gtk.Image.from_icon_name ("gtk-dialog-error", Gtk.IconSize.DIALOG));
				break;
			case Gtk.MessageType.WARNING:
				content.add (new Gtk.Image.from_icon_name ("gtk-dialog-warning", Gtk.IconSize.DIALOG));
				break;
		}
		content.add (new Gtk.Label (text));
		infoBar.show_all ();
		infoBox.add (infoBar);
		infoBar.response.connect (() => {
			infoBar.destroy ();
			//hide();
		});
		if (info_timeout_id > 0) {
			GLib.Source.remove (info_timeout_id);
		}
		info_timeout_id = GLib.Timeout.add (10000, on_info_timeout);
		return -1;
	}

	private bool on_info_timeout () {
		if (infoBar != null)
			infoBar.destroy ();
		return false;
	}

	public int show_warning (string text = "") {
		return show_message (text, MessageType.WARNING);
	}

	public int show_info (string text = "") {
		return show_message (text, MessageType.INFO);
	}

	public int show_error (string text = "") {
		return show_message (text, MessageType.ERROR);
	}

	public Query query {
		get {
			return editor.query;
		}
	}

	public void show_results () {
		Debug.info (this.name, "show_results () reached");
		//result_view.connect_model ();
		set_subtitle ();
		button_go.active = false;
		while (Gtk.events_pending ())
			Gtk.main_iteration ();
	}
}
