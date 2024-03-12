# Pantheon Polkit Agent
[![Translation status](https://l10n.elementary.io/widgets/desktop/-/pantheon-agent-polkit/svg-badge.svg)](https://l10n.elementary.io/engage/desktop/?utm_source=widget)

![](https://raw.githubusercontent.com/elementary/pantheon-agent-polkit/master/data/screenshot.png)

## Building, Testing, and Installation

You'll need the following dependencies:
* accountsservice
* libgranite-7-dev (>= 7.0.0)
* libgtk-4-dev
* libadwaita-1-dev
* libpolkit-gobject-1-dev
* libpolkit-agent-1-dev
* meson
* valac (>= 0.34.1)

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
