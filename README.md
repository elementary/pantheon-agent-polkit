# Pantheon Polkit Agent
[![Translation status](https://l10n.elementary.io/widgets/desktop/pantheon-agent-polkit/-/svg-badge.svg)](https://l10n.elementary.io/projects/desktop/pantheon-agent-polkit/?utm_source=widget)

## Building, Testing, and Installation

You'll need the following dependencies:
* cmake
* cmake-elementary
* libgtk-3-dev
* libpolkit-gobject-1-dev
* libpolkit-agent-1-dev
* valac (>= 0.34.1)

It's recommended to create a clean build environment

    mkdir build
    cd build/

Run `cmake` to configure the build environment and then `make` to build and run automated tests

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make

To install, use `make install`

    sudo make install
