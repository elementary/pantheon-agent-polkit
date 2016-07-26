include(Translations)

configure_file(org.pantheon.agent-polkit.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.pantheon.agent-polkit.desktop DESTINATION share/applications)
