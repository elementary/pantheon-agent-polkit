project(
    'io.elementary.desktop.agent-polkit',
    'vala', 'c',
    version: '8.0.1'
)

install_path = join_paths(get_option('prefix'), get_option('libexecdir'), 'policykit-1-pantheon')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/Agent.vala',
    'src/PolkitDialog.vala',
    'src/Interfaces.vala',
    dependencies: [
        dependency('libadwaita-1'),
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7', version: '>=7.0.0'),
        dependency('gtk4'),
        dependency('polkit-agent-1'),
        dependency('polkit-gobject-1'),
        dependency('pantheon-wayland-1'),
        meson.get_compiler('vala').find_library('posix')
    ],
    c_args: [
        '-DPOLKIT_AGENT_I_KNOW_API_IS_SUBJECT_TO_CHANGE',
    ],
    install: true,
    install_dir: install_path
)

conf_data = configuration_data()
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('PKEXECDIR', install_path)

subdir('data')
subdir('po')
