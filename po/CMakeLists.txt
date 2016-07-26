include (Translations)
add_translations_directory(${GETTEXT_PACKAGE})
add_translations_catalog(${GETTEXT_PACKAGE}
    ../src/
    DESKTOP_FILES
        ${CMAKE_SOURCE_DIR}/data/org.pantheon.agent-polkit.desktop.in
)
