# Desktop File
desktop_in = configure_file(
    input: 'agent-polkit.desktop.in.in',
    output: '@BASENAME@',
    configuration: conf_data
)

i18n.merge_file(
    input: desktop_in,
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.project_source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: 'agent-polkit.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    install: true,
    install_dir: get_option('datadir') / 'metainfo',
    po_dir: meson.project_source_root () / 'po' / 'extra'
)

# Daemon File
configure_file(
    input: 'agent-polkit-daemon.desktop.in',
    output: meson.project_name() + '.desktop',
    configuration: conf_data,
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)
