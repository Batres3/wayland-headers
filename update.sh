#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Fetching latest revisions..."

LIBDECOR_REV=$(git ls-remote https://gitlab.freedesktop.org/libdecor/libdecor.git HEAD | cut -f1)
echo "  LIBDECOR_REV=$LIBDECOR_REV"

WAYLAND_REV=$(git ls-remote https://gitlab.freedesktop.org/wayland/wayland.git HEAD | cut -f1)
echo "  WAYLAND_REV=$WAYLAND_REV"

WAYLAND_PROTOCOLS_REV=$(git ls-remote https://gitlab.freedesktop.org/wayland/wayland-protocols.git HEAD | cut -f1)
echo "  WAYLAND_PROTOCOLS_REV=$WAYLAND_PROTOCOLS_REV"

sed -i.bak \
    -e "s|^LIBDECOR_REV=.*|LIBDECOR_REV=$LIBDECOR_REV|" \
    -e "s|^WAYLAND_REV=.*|WAYLAND_REV=$WAYLAND_REV|" \
    -e "s|^WAYLAND_PROTOCOLS_REV=.*|WAYLAND_PROTOCOLS_REV=$WAYLAND_PROTOCOLS_REV|" \
    generate.sh && rm -f generate.sh.bak

echo "Updated generate.sh. Run ./generate.sh to regenerate."
