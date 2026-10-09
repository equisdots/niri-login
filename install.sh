#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# equisdots niri · niri-login — installer
#
# Installs (or removes) the niri Wayland session entry so display managers
# (SDDM, GDM, greetd + a Wayland-aware greeter, ...) list "Niri" at login.
#
# Why this exists: display managers do NOT scan ~/.local/share/wayland-sessions
# by default, so a user-local session file is invisible. This installer places
# the entry in a system-scanned directory (/usr/local/share/wayland-sessions or
# /usr/share/wayland-sessions) using sudo.
#
# Usage:
#   ./install.sh [--system|--user] [--dir DIR] [--remove|--status] [-n] [-y]
#
#   --system   install into the system wayland-sessions dir (default)
#   --user     install into ~/.local/share/wayland-sessions (not always scanned)
#   --dir DIR  force a target directory
#   --remove   remove the entry this installer created (marker-checked)
#   --status   report where the entry is installed
#   -n         dry run
#   -y         assume yes (no prompts)
#
# Environment overrides (useful for tests):
#   NIRI_LOGIN_DIR   same as --dir
#   NIRI_LOGIN_SUDO  command used for privileged ops (default: sudo)
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

MARKER="equisdots-niri-login"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_SRC="$SCRIPT_DIR/session/niri.desktop"

MODE="system"
ACTION="install"
TARGET_DIR="${NIRI_LOGIN_DIR:-}"
DRY_RUN=0
ASSUME_YES=0

msg()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m error:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (($#)); do
    case "$1" in
        --system)           MODE="system" ;;
        --user)             MODE="user" ;;
        --dir)              TARGET_DIR="${2:?--dir needs a value}"; shift ;;
        --remove|--uninstall) ACTION="remove" ;;
        --status)           ACTION="status" ;;
        -n|--dry-run)       DRY_RUN=1 ;;
        -y|--yes)           ASSUME_YES=1 ;;
        -h|--help)          usage; exit 0 ;;
        *)                  die "unknown option: $1 (try --help)" ;;
    esac
    shift
done

target_dir() {
    if [[ -n "$TARGET_DIR" ]]; then
        printf '%s' "$TARGET_DIR"
    elif [[ "$MODE" == "user" ]]; then
        printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/wayland-sessions"
    elif [[ -d /usr/local/share ]]; then
        printf '%s' "/usr/local/share/wayland-sessions"
    else
        printf '%s' "/usr/share/wayland-sessions"
    fi
}

# Run a command with privileges when installing to a system location.
run_root() {
    if [[ "$MODE" == "user" || "$(id -u)" -eq 0 || -n "$TARGET_DIR" ]]; then
        "$@"
    else
        "${NIRI_LOGIN_SUDO:-sudo}" "$@"
    fi
}

# Directories to scan for an existing entry (target first when forced).
scan_dirs() {
    [[ -n "$TARGET_DIR" ]] && printf '%s\n' "$TARGET_DIR"
    printf '%s\n' \
        /usr/share/wayland-sessions \
        /usr/local/share/wayland-sessions \
        "${XDG_DATA_HOME:-$HOME/.local/share}/wayland-sessions"
}

# A distro/user niri.desktop that is not ours (no marker).
foreign_session_file() {
    local d f
    while IFS= read -r d; do
        f="$d/niri.desktop"
        [[ -f "$f" ]] || continue
        grep -q "$MARKER" "$f" 2>/dev/null && continue
        printf '%s' "$f"
        return 0
    done < <(scan_dirs)
    return 1
}

installed_ours() {
    local d f
    while IFS= read -r d; do
        f="$d/niri.desktop"
        [[ -f "$f" ]] || continue
        grep -q "$MARKER" "$f" 2>/dev/null && { printf '%s' "$f"; return 0; }
    done < <(scan_dirs)
    return 1
}

do_status() {
    local f
    if f="$(installed_ours)"; then
        ok "niri session entry installed: $f"
    elif f="$(foreign_session_file)"; then
        ok "niri session entry provided by the distro: $f"
    else
        warn "no niri session entry found (run: install.sh)"
        exit 1
    fi
}

do_remove() {
    local f
    if ! f="$(installed_ours)"; then
        warn "no niri-login entry owned by this installer; nothing to remove"
        return 0
    fi
    if (( DRY_RUN )); then
        msg "[dry-run] would remove $f"
        return 0
    fi
    run_root rm -f "$f"
    ok "removed $f"
}

do_install() {
    [[ -f "$SESSION_SRC" ]] || die "missing payload: $SESSION_SRC"

    if ! command -v niri-session >/dev/null 2>&1; then
        warn "niri-session not found on PATH; the session entry will not start until niri is installed"
    fi

    # Never create a duplicate: if the distro already ships an entry, keep it.
    local foreign
    if foreign="$(foreign_session_file)"; then
        ok "a niri session entry already exists ($foreign); leaving it in place"
        return 0
    fi

    local dir f
    dir="$(target_dir)"
    f="$dir/niri.desktop"
    msg "installing niri session entry -> $f"

    if (( DRY_RUN )); then
        msg "[dry-run] mkdir -p $dir && install $SESSION_SRC $f"
        return 0
    fi

    run_root mkdir -p "$dir"
    if [[ "$MODE" != "user" && "$(id -u)" -ne 0 && -z "$TARGET_DIR" ]]; then
        run_root install -m 0644 "$SESSION_SRC" "$f"
    else
        install -m 0644 "$SESSION_SRC" "$f"
    fi
    ok "niri session entry installed"
}

case "$ACTION" in
    install) do_install ;;
    remove)  do_remove ;;
    status)  do_status ;;
esac
