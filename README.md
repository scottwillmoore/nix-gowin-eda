# GOWIN EDA

Nix packages of [GOWIN EDA](https://www.gowinsemi.com/en/support/home/).

## Overview

At the moment only the **Education** edition is supported, as it requires no
runtime license files.

GOWIN EDA is shipped as pre-built, dynamically linked binaries. The majority of
the bundled libraries are preserved. There is no easy way to replace the bundled
Qt libraries and plugins with the `nixpkgs` versions. Unfortunately, because the
bundled Qt plugins do not support Wayland, the application is forced to run
through XWayland.

## Usage

The flake exposes the packages and an overlay. The easiest way to get started is
with `nix run`:

```sh
nix run github:scottwillmoore/nix-gowin-eda#gowin-eda-education
```
