project(
  'co.tauos.Enigma', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2', ],
)

if get_option('development')
  app_id = meson.project_name() + '.Devel'
  name_suffix = ' (Development)'
else
  app_id = meson.project_name()
  name_suffix = ''
endif

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('NAME_SUFFIX', name_suffix)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', app_id)
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set10('DEVELOPMENT', get_option('development'))

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

asresources = gnome.compile_resources(
	'as-resources', join_paths(meson.project_source_root(), 'data', meson.project_name() + '.gresources.xml'),
	source_dir: join_paths(meson.project_source_root(), 'data'),
	c_name: 'as'
)

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true
)