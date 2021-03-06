/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */

[GtkTemplate (ui = "/org/baedert/corebird/ui/settings-dialog.ui")]
class SettingsDialog : Gtk.Window {
  [GtkChild]
  private Gtk.Switch on_new_mentions_switch;
  [GtkChild]
  private Gtk.Switch round_avatar_switch;
  [GtkChild]
  private Gtk.Switch on_new_dms_switch;
  [GtkChild]
  private Gtk.ComboBoxText on_new_tweets_combobox;
  [GtkChild]
  private Gtk.Switch auto_scroll_on_new_tweets_switch;
  [GtkChild]
  private Gtk.SpinButton max_media_size_spin_button;
  [GtkChild]
  private Gtk.Stack main_stack;

  public SettingsDialog (Corebird application) {
    this.application = application;
    this.type_hint   = Gdk.WindowTypeHint.DIALOG;

    // Notifications Page
    Settings.get ().bind ("round-avatars", round_avatar_switch, "active",
                          SettingsBindFlags.DEFAULT);
    Settings.get ().bind ("new-tweets-notify", on_new_tweets_combobox, "active-id",
                          SettingsBindFlags.DEFAULT);
    Settings.get ().bind ("new-mentions-notify", on_new_mentions_switch, "active",
                          SettingsBindFlags.DEFAULT);
    Settings.get ().bind ("new-dms-notify", on_new_dms_switch, "active",
                          SettingsBindFlags.DEFAULT);

    // Interface page
    auto_scroll_on_new_tweets_switch.notify["active"].connect (() => {
      on_new_tweets_combobox.sensitive = !auto_scroll_on_new_tweets_switch.active;
    });
    Settings.get ().bind ("auto-scroll-on-new-tweets", auto_scroll_on_new_tweets_switch, "active",
                          SettingsBindFlags.DEFAULT);
    Settings.get ().bind ("max-media-size", max_media_size_spin_button, "value",
                          SettingsBindFlags.DEFAULT);

    add_accels ();
    load_geometry ();
    show_all ();
  }

  [GtkCallback]
  private bool window_destroy_cb () {
    save_geometry ();
    return false;
  }

  private void load_geometry () {
    GLib.Variant geom = Settings.get ().get_value ("settings-geometry");
    int x = 0,
        y = 0,
        w = 0,
        h = 0;
    x = geom.get_child_value (0).get_int32 ();
    y = geom.get_child_value (1).get_int32 ();
    w = geom.get_child_value (2).get_int32 ();
    h = geom.get_child_value (3).get_int32 ();
    if (w == 0 || h == 0)
      return;

    move (x, y);
    resize (w, h);
  }

  private void save_geometry () {
    var builder = new GLib.VariantBuilder (GLib.VariantType.TUPLE);
    int x = 0,
        y = 0,
        w = 0,
        h = 0;
    get_position (out x, out y);
    w = get_allocated_width ();
    h = get_allocated_height ();
    builder.add_value (new GLib.Variant.int32(x));
    builder.add_value (new GLib.Variant.int32(y));
    builder.add_value (new GLib.Variant.int32(w));
    builder.add_value (new GLib.Variant.int32(h));
    Settings.get ().set_value ("settings-geometry", builder.end ());
  }

  private void add_accels () {
    Gtk.AccelGroup ag = new Gtk.AccelGroup();

    ag.connect (Gdk.Key.Escape, 0, Gtk.AccelFlags.LOCKED,
        () => {this.destroy (); return true;});
    ag.connect (Gdk.Key.@1, Gdk.ModifierType.MOD1_MASK, Gtk.AccelFlags.LOCKED,
        () => {main_stack.visible_child_name = "interface"; return true;});
    ag.connect (Gdk.Key.@2, Gdk.ModifierType.MOD1_MASK, Gtk.AccelFlags.LOCKED,
        () => {main_stack.visible_child_name = "notifications"; return true;});

    this.add_accel_group(ag);
  }
}
