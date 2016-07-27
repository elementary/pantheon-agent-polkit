vala_precompile(VALA_C ${EXEC_NAME}
    Agent.vala
    PolkitDialog.vala
    Interfaces.vala
    Utils.vala
PACKAGES
    gtk+-3.0
    polkit-agent-1
    polkit-gobject-1
    posix
OPTIONS
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
  --target-glib=2.32
  --thread
)

add_executable (${EXEC_NAME} ${VALA_C})
target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} DESTINATION ${EXECDIR})

