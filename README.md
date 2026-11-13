# equisdots niri — niri-login

Installs the **niri Wayland session entry** so your display manager (SDDM, GDM,
or any greeter that reads `wayland-sessions`) lists "Niri" at login.

## Why this repo exists

Display managers scan system directories:

- `/usr/local/share/wayland-sessions`
- `/usr/share/wayland-sessions`

They do **not** scan `~/.local/share/wayland-sessions` by default, so a
user-local session file does not appear. That is why the entry must be placed in
a system-scanned directory, which is what this installer does (with `sudo`).

Some distributions already ship `niri.desktop` with the niri package; in that
case this installer detects it and leaves it in place instead of creating a
duplicate.

## Install

```sh
git clone https://github.com/equisdots/niri-login.git
cd niri-login
./install.sh            # system install (sudo), skipped if a distro entry exists
./install.sh --status   # show where the entry lives
./install.sh --remove   # remove only the entry this installer created
```

Options: `--system` (default), `--user` (writes to
`~/.local/share/wayland-sessions`, not always scanned), `--dir DIR`, `-n`
(dry-run), `-y`.

From the meta installer: `dotsniri login install|remove|status`.

## Entry

`session/niri.desktop`:

```ini
[Desktop Entry]
Name=Niri
Comment=equisdots niri session
Exec=niri-session
Type=Application
DesktopNames=niri
# equisdots-niri-login
```

The trailing comment is a marker: removal only ever deletes a file carrying it,
so a distro-provided entry is never touched.

`niri-session` also exports `XDG_CURRENT_DESKTOP=niri` and `NIRI_SOCKET` to the
session processes. The Quickshell shell and the plugin deployment rely on those
signals to select the niri backend/plugin paths, so start niri through this
entry (or `niri-session` directly) rather than a bare `niri` binary.

## License

AGPL-3.0-or-later — see [LICENSE](LICENSE). Copyright (C) 2026 xscriptor <x@xscriptor.com>.

This repository is licensed under the GNU Affero General Public License, version 3 or any later version. If you modify the software and let users interact with it over a network, you must offer them the corresponding source.

Releases published before 2026-11-13 were distributed under the MIT License and remain available under those terms.

Third-party components, fonts, icons, images, sounds, vendored code and other assets keep their original licenses and are not covered by this license. See THIRD-PARTY.md / CREDITS.md where present.
