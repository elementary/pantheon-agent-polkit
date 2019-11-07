# Desktop File
desktop_in = configure_file(
    input: 'io.elementary.pantheon-agent-polkit.desktop.in.in',
    output: '@BASENAME@',
    configuration: conf_data
)

i18n.merge_file(
    input: desktop_in,
    output: '@BASENAME@',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: 'agent-polkit.appdata.xml.in',
    output: 'io.elementary.desktop.agent-polkit.appdata.xml',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
    po_dir: join_paths(meson.source_root (), 'po', 'extra')
)

# Daemon File
configure_file(
    input: 'io.elementary.pantheon-agent-polkit-daemon.desktop.in',
    output: '@BASENAME@',
    configuration: conf_data,
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)
