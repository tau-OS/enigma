blueprints = custom_target('blueprints',
  input: files(
    'main_window.blp',
    'menu.blp',
    'prefs.blp',
  ),
  output: ['.'],
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)