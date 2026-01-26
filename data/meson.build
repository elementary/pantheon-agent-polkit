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

systemd_user_unit_dir = get_option('systemduserunitdir')

if systemd_user_unit_dir != 'no'
    systemd = dependency('systemd')
    prefix = get_option('prefix')
    if systemd_user_unit_dir == ''
        systemd_user_unit_dir = systemd.get_variable('systemduserunitdir', pkgconfig_define: ['prefix', prefix])
    endif

    # Daemon File
    configure_file(
        input: 'agent-polkit-daemon.service.in',
        output: meson.project_name() + '.service',
        configuration: conf_data,
        install_dir: systemd_user_unit_dir
    )
endif
