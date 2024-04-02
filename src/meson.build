filefinder_sources = [
  #'base/filter.vala',
  #'base/filter-bin.vala',
  #'base/filter-files.vala',
  #'base/filter-location.vala',
  #'base/filter-mask.vala',
  #'base/filter-mime.vala',
  #'base/filter-modified.vala',
  #'base/filter-none.vala',
  #'base/filter-size.vala',
  #'base/filter-text.vala',
  #'base/plugin.vala',
  #'base/query.vala',
  #'base/service.vala',

  #'common/debug.vala',
  'common/text.vala',

  #'gui/column-menu-item.vala',
  #'gui/dialog-mime-chooser.vala',
  #'gui/file-finder-window.vala',
  #'gui/filter-bar.vala',
  #'gui/input-dialog.vala',
  #'gui/menu-item-id.vala',
  #'gui/mime-button.vala',
  #'gui/page-plugin.vala',
  #'gui/preferences.vala',
  #'gui/query-editor.vala',
  #'gui/query-row.vala',
  #'gui/results-view.vala',
  #'gui/toolbar.vala',
  #'gui/tool-button.vala',

  'filefinder.vala',
]

filefinder_SOURCES = [
  filefinder_sources,
  'main.vala',
]

filefinder_deps = [
  glib_dep,
  gio_dep,
  gio_unix_dep,
  # gtk3_dep,
  gtk4_dep,
  adw1_dep,
  posix_dep,
]

filefinder_c_args = [
  '-DPACKAGE_SRC_DIR='.format(meson.current_source_dir()),
  '-include', 'config.h',
]

filefinder_vala_args = [
  '--target-glib', '2.38',
  '--pkg', 'config',
]

if (valac.version().version_compare('>=0.36'))
  filefinder_vala_args += [
    '-D','HAVE_VALA36'
  ]
endif

if (gtk3_dep.version().version_compare('>=3.20'))
  filefinder_vala_args += [
    '-D', 'HAVE_GTK320'
  ]
endif

filefinder_link_args = [
  '-Wl,--export-dynamic',
]

executable(meson.project_name(),
  filefinder_SOURCES,
  include_directories: config_h_dir,
  dependencies: filefinder_deps,
  vala_args: filefinder_vala_args,
  c_args: filefinder_c_args,
  link_args: filefinder_link_args,
  install: true,
)

if not get_option('without_nautilus_extension')
#  subdir('nautilus')
endif

# Unit tests for filefinder
# test_bin = executable('tests_filefinder',
#   [ filefinder_sources,
#     'tests.vala',
#   ],
#   include_directories: config_h_dir,
#   dependencies: filefinder_deps,
#   vala_args: filefinder_vala_args,
#   c_args: filefinder_c_args,
#   link_args: filefinder_link_args,
# )

# test('tests_filefinder',
#   test_bin,
# )

