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

## License

MIT.
