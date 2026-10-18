# GOWIN EDA

Nix packages of [GOWIN EDA](https://www.gowinsemi.com/en/support/home/).

## Packages

At the moment only the **Education** edition is supported.

| Attribute             | Version     |
| --------------------- | ----------- |
| `gowin-eda-education` | `1.9.11.03` |

## Notes

GOWIN EDA is shipped as pre-built, dynamically linked binaries. The majority of
the bundled libraries are preserved. There is no easy way to replace the bundled
Qt libraries and plugins with the `nixpkgs` versions. Unfortunately the bundled
Qt plugins do not support Wayland thus the application must be forced to run
through XWayland.
