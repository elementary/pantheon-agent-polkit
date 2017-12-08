i18n.merge_file(
    input: 'org.pantheon.agent-polkit.desktop.in.in',
    output: 'org.pantheon.agent-polkit.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: 'org.pantheon.agent-polkit-daemon.desktop.in',
    output: 'org.pantheon.agent-polkit-daemon.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)
