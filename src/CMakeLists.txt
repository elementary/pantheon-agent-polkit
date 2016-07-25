vala_precompile(VALA_C ${EXEC_NAME}
    Agent.vala
    PolkitDialog.vala
PACKAGES
    granite
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

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

