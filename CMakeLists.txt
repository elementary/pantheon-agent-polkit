project (pantheon-agent-polkit)
cmake_minimum_required (VERSION 2.8)

include (GNUInstallDirs)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (EXEC_NAME ${CMAKE_PROJECT_NAME})
set (VERSION "0.1.3")
set (DOLLAR "$")

set (PKEXECDIR "${CMAKE_INSTALL_FULL_LIBEXECDIR}/policykit-1-pantheon")

add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_definitions (-w)
add_definitions (-DPOLKIT_AGENT_I_KNOW_API_IS_SUBJECT_TO_CHANGE)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED gtk+-3.0 polkit-agent-1 polkit-gobject-1)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.34.1" MINIMUM)

include (ValaPrecompile)

add_subdirectory (po)
add_subdirectory (src)
add_subdirectory (data)
