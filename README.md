# wayland-headers packaged for the Zig build system

This is a Zig package which provides various Wayland headers needed to develop and cross-compile.

It includes:

* non-generated Wayland headers (see `wayland/`)

* generated headers for Wayland protocols (see `wayland-protocols/`):

  * idle-inhibit-unstable-v1
  * pointer-constraints-unstable-v1
  * relative-pointer-unstable-v1
  * viewporter
  * xdg-decoration
  * xdg-shell

* And headers for libdecor (see `libdecor/`)


## Updating

To regenerate the contents of this repository using the upstream version it currently targets, run `./generate.sh`.

To update this repository to the latest upstream version, run `./update.sh` then `./generate.sh`.

## Verifying repository contents

For supply chain security reasons (e.g. to confirm we made no patches to the code) we provide a `git diff` command you can run to verify the contents of this repository:

```sh
./verify.sh
```

If nothing is printed, there is no diff. Deleted files, and changes to `README.md`, `build.zig`, `.github` CI files and `.gitignore` are ignored.

## Issues

Issues are tracked in the [main Mach repository](https://github.com/hexops/mach/issues?q=is%3Aissue+is%3Aopen+label%3Awayland-headers).
