#!/usr/bin/env bash
# equisdots niri · niri-login — uninstall wrapper.
# Removes only the session entry this installer created (marker-checked).
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" --remove "$@"
