project(
    'io.elementary.desktop.agent-polkit',
    'vala', 'c',
    version: '1.0.2'
)

install_path = join_paths(get_option('prefix'), get_option('libexecdir'), 'policykit-1-pantheon')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

executable(
    meson.project_name(),
    'src/Agent.vala',
    'src/PolkitDialog.vala',
    'src/Interfaces.vala',
    'src/Utils.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite', version: '>=5.4.0'),
        dependency('gtk+-3.0'),
        dependency('polkit-agent-1'),
        dependency('polkit-gobject-1'),
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
