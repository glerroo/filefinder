project('filefinder', ['vala', 'c'],
          version: '1.0',
          license: 'GPL-3.0-or-later',
    license_files: 'COPYING',
    meson_version: '>= 1.1.0',
  default_options: [
    'buildtype=debugoptimized',
    'warning_level=3',
  ],
)

gnome = import('gnome')

# Add our custom VAPI dir
add_project_arguments(
  ['--vapidir', join_paths(meson.global_source_root(), 'vapi')],
  language: 'vala'
)

# Paths
prefix = get_option ('prefix')
locale_dir = join_paths (prefix, get_option ('localedir'))
data_dir = join_paths (prefix, get_option ('datadir'))
config_h_dir = include_directories('.')

# Common variables
valac = meson.get_compiler('vala')

# Dependencies
glib_dep = dependency('glib-2.0', version: '>=2.38')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gtk3_dep = dependency('gtk+-3.0')
gtk4_dep = dependency('gtk4')
adw1_dep = dependency('libadwaita-1', version: '>= 1.4')
posix_dep = valac.find_library('posix')


# Configuration
conf = configuration_data()
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PACKAGE_DATA_DIR', join_paths(data_dir, meson.project_name()))
conf.set_quoted('PACKAGE_LOCALE_DIR', locale_dir)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('TEMPLATE_DIR', join_paths(data_dir, meson.project_name(), 'templates'))
configure_file(output: 'config.h', configuration: conf)

subdir('data')
subdir('man')
subdir('src')

gnome.post_install(
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)

