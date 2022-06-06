sources = [
  'app.vala',
  'window.vala',
]

configure_file(output: 'config.h', configuration: conf)

dependencies = [
  dependency('gio-2.0'),
  dependency('gtk4'),
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gee-0.8'),
  dependency('libhelium-1'),
]

gnome = import('gnome')

executable(
  meson.project_name(),
  sources,
  asresources,
  vala_args: [
    '--target-glib=2.50',
    meson.project_source_root() / 'src' / 'config.vapi',
  ],
  dependencies: dependencies,
  install : true
)