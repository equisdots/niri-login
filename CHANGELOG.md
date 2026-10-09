# Changelog

All notable changes to `niri-login` are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-09

First release: installs the niri Wayland session entry into a system-scanned
`wayland-sessions` directory so display managers list "Niri" at login.

### Added

- `session/niri.desktop`, the session entry (`Name=Niri`,
  `Exec=niri-session`) carrying the marker comment `# equisdots-niri-login`.
- `install.sh` with `--system`, `--user`, `--dir`, `--remove`, `--status`,
  `-n` / `--dry-run`, `-y` / `--yes`, and the `NIRI_LOGIN_DIR` /
  `NIRI_LOGIN_SUDO` environment overrides.
- `uninstall.sh`, a thin wrapper around `install.sh --remove`.
- Duplicate detection: a distro-provided `niri.desktop` is detected and left
  in place, and `--remove` deletes only the entry carrying the marker.
- `docs/wayland-sessions.md` explaining the display-manager scan rules.

### Notes

- Display managers scan `/usr/local/share/wayland-sessions` and
  `/usr/share/wayland-sessions`; they do not scan
  `~/.local/share/wayland-sessions` by default.
- `--user` writes to the user-local path, which most display managers ignore
  unless explicitly configured to scan it.

[Unreleased]: https://github.com/equisdots/niri-login/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/equisdots/niri-login/releases/tag/v0.1.0
