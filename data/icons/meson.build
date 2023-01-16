icondir = join_paths(get_option('datadir'), 'icons/hicolor')

install_data(
  'co.tauos.Enigma.svg'.format(app_id),
  install_dir: join_paths(icondir, 'scalable/apps'),
)

install_data(
  'co.tauos.Enigma.svg'.format(app_id),
  install_dir: join_paths(icondir, 'scalable/apps', '@0@.Devel.svg'.format(app_id)),
)

install_data(
  'co.tauos.Enigma-symbolic.svg'.format(app_id),
  install_dir: join_paths(icondir, 'symbolic/apps'),
  rename: '@0@-symbolic.svg'.format(app_id),
)
