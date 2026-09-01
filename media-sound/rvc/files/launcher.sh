#!/bin/sh
set -e

USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/@PN@"
mkdir -p "${USER_DIR}"

# Populate/update symlink farm from system installation to user workspace
lndir -silent "@EPREFIX@/usr/share/@PN@" "${USER_DIR}"

# Copy default config template if user config does not exist
if [ ! -f "${USER_DIR}/configs/config.json" ] && [ -f "@EPREFIX@@EXAMPLES@/config.json" ]; then
    cp "@EPREFIX@@EXAMPLES@/config.json" "${USER_DIR}/configs/config.json"
fi

cd "${USER_DIR}"

# Auto-detect PipeWire and wrap execution in pw-jack for low-latency JACK I/O
if command -v pw-jack >/dev/null 2>&1 && [ -S "${XDG_RUNTIME_DIR}/pipewire-0" ]; then
    exec pw-jack "@EPYTHON@" "$@"
else
    exec "@EPYTHON@" "$@"
fi
