include(Translations)

configure_file(org.pantheon.agent-polkit-daemon.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit-daemon.desktop)
configure_file(org.pantheon.agent-polkit.desktop.in.in ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop.in)
configure_file_translation(${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop ${CMAKE_SOURCE_DIR}/po/)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop DESTINATION share/applications)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit-daemon.desktop DESTINATION ${CMAKE_INSTALL_FULL_SYSCONFDIR}/xdg/autostart)