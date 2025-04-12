# GOWIN EDA

> This is a work in progress! I haven't got it to work yet! Please see my [HELPME](./HELPME.md)!

## Commands

### `gowin-eda-education-unwrapped`

```sh
# Enter a temporary directory
mkdir build/ && cd build/

# Enter the development shell for the package
nix develop --file ../ gowin-eda-education-unwrapped

# Run the unpack and patch phases
phases="${prePhases[*]:-} unpackPhase patchPhase" genericBuild

# Run the configure, build and check phases
phases="${preConfigurePhases[*]:-} configurePhase ${preBuildPhases[*]:-} buildPhase checkPhase" genericBuild

# Run the install and fixup phases
rm -r outputs/ && phases="${preInstallPhases[*]:-} installPhase ${preFixupPhases[*]:-} fixupPhase" genericBuild | tee build.log
```

### `gowin-eda-education`

```sh
# Build and run the FHS environment which contains the package
nix run --file ./ gowin-eda-education

# Run the binary with LD debug output
LD_DEBUG=libs /bin/gw_ide

# Run the binary with QT debug output
QT_DEBUG_PLUGINS=1 /bin/gw_ide
```

## References

- [GOWIN EDA](https://www.gowinsemi.com/en/support/home/)
- [GOWIN EDA: Download](https://www.gowinsemi.com/en/support/download_eda/)
- [GOWIN EDA: Quick Installation Guide](https://www.gowinsemi.com/upload/database_doc/1876/document/656998e73085b.pdf)

- [Sipeed: Install IDE](https://wiki.sipeed.com/hardware/en/tang/common-doc/install-the-ide.html)

- [AUR: `gowin-eda`](https://aur.archlinux.org/pkgbase/gowin-eda)
- [NUR: `ryan4yin/gowin-eda-edu-ide`](https://github.com/nix-community/nur-combined/tree/main/repos/ryan4yin/pkgs/gowin-eda-edu-ide)

- [Open FPGA Loader](https://github.com/trabucayre/openFPGALoader)
- [Project Apicula](https://github.com/YosysHQ/apicula)
