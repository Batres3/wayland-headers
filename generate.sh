#!/usr/bin/env bash
set -euo pipefail
set -x

LIBDECOR_REV=7807ae3480f5c6a37c5e8505d94af1e764aaf704
WAYLAND_REV=edb943dc6464697ba13d7df277aef277721764b7
WAYLAND_PROTOCOLS_REV=e1d61ce9402ebd996d758c43f167e6280c1a3568

# `git clone --depth 1` but at a specific revision
git_clone_rev() {
    repo=$1
    rev=$2
    dir=$3

    rm -rf "$dir"
    mkdir "$dir"
    pushd "$dir"
    git init -q
    git fetch "$repo" "$rev" --depth 1
    git checkout -q FETCH_HEAD
    popd
}

rm -rf libdecor wayland wayland-protocols
mkdir libdecor wayland wayland-protocols


# install headers for libdecor
git_clone_rev https://gitlab.freedesktop.org/libdecor/libdecor.git "$LIBDECOR_REV" _libdecor
mv _libdecor/src/*.h libdecor
cp _libdecor/LICENSE libdecor/


git_clone_rev https://gitlab.freedesktop.org/wayland/wayland.git "$WAYLAND_REV" _wayland

# install/generate headers as per https://gitlab.freedesktop.org/wayland/wayland/-/blob/main/src/meson.build
mv _wayland/src/wayland{-util,-server{,-core},-client{,-core}}.h wayland
# generate version header
version=$(grep -o '\bversion:\s'\''[^'\'']*' _wayland/meson.build | cut -d \' -f 2)
parts=(${version//./ })
sed \
    -e "s/@WAYLAND_VERSION@/$version/" \
    -e "s/@WAYLAND_VERSION_MAJOR@/${parts[0]}/" \
    -e "s/@WAYLAND_VERSION_MINOR@/${parts[1]}/" \
    -e "s/@WAYLAND_VERSION_MICRO@/${parts[2]}/" \
    _wayland/src/wayland-version.h.in > wayland/wayland-version.h

# build wayland-scanner from source (requires expat)
python3 _wayland/src/embed.py _wayland/protocol/wayland.dtd wayland_dtd > _wayland/src/wayland.dtd.h
cc -I _wayland/src -I _wayland/protocol -I wayland -o _wayland/wayland-scanner \
    _wayland/src/scanner.c _wayland/src/wayland-util.c \
    -lexpat
WAYLAND_SCANNER=_wayland/wayland-scanner

# generate main protocol headers
"$WAYLAND_SCANNER" server-header _wayland/protocol/wayland.xml wayland/wayland-server-protocol.h
"$WAYLAND_SCANNER" client-header _wayland/protocol/wayland.xml wayland/wayland-client-protocol.h
cp _wayland/COPYING wayland/


git_clone_rev https://gitlab.freedesktop.org/wayland/wayland-protocols.git "$WAYLAND_PROTOCOLS_REV" _wayland-protocols

# generates wayland protocol headers specifically for GLFW
generate_glfw() {
    xml=$1
    out_name=$2

    "$WAYLAND_SCANNER" client-header "$xml" "wayland-protocols/wayland-$out_name-client-protocol.h"
    "$WAYLAND_SCANNER" private-code "$xml" "wayland-protocols/wayland-$out_name-client-protocol-code.h"
}

# from https://github.com/glfw/glfw/blob/master/src/CMakeLists.txt#L95-L115
generate_glfw _wayland-protocols/stable/xdg-shell/xdg-shell.xml xdg-shell
generate_glfw _wayland-protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml xdg-decoration
generate_glfw _wayland-protocols/stable/viewporter/viewporter.xml viewporter
generate_glfw _wayland-protocols/unstable/relative-pointer/relative-pointer-unstable-v1.xml relative-pointer-unstable-v1
generate_glfw _wayland-protocols/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml pointer-constraints-unstable-v1
generate_glfw _wayland-protocols/unstable/idle-inhibit/idle-inhibit-unstable-v1.xml idle-inhibit-unstable-v1

# for the main protocol the header has already been generated, so we only need the code
"$WAYLAND_SCANNER" private-code _wayland/protocol/wayland.xml wayland-protocols/wayland-client-protocol-code.h
cp _wayland-protocols/COPYING wayland-protocols/


rm -rf _libdecor _wayland _wayland-protocols 
