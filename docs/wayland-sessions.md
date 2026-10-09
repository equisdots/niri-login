# Wayland session discovery

Display managers (SDDM, GDM, greetd with a Wayland-aware greeter, and others)
build their session list by scanning a fixed set of directories for
`*.desktop` files. This document explains which directories are scanned, how
`niri-login` avoids duplicates, and the caveat around `--user`.

## Which directories are scanned

The conventional Wayland session directories are:

- `/usr/share/wayland-sessions`
- `/usr/local/share/wayland-sessions`

These are the same paths the session lookup in `libwayland` / greeter
implementations uses. SDDM's stock `SessionDir` default includes both, so an
entry placed in either directory appears in its session menu.

Display managers do **not** scan `~/.local/share/wayland-sessions` by default.
A session file placed there is invisible unless the display manager is
explicitly configured to read the user-local path, which is why the installer
targets a system directory (with `sudo`) by default.

The installer picks `/usr/local/share/wayland-sessions` when `/usr/local/share`
exists and falls back to `/usr/share/wayland-sessions` otherwise. `--dir DIR`,
`--system`, and `--user` override this choice; `NIRI_LOGIN_DIR` is the scripted
equivalent of `--dir`.

## Marker and duplicate behaviour

The installed entry, `session/niri.desktop`, ends with a marker comment:

```ini
# equisdots-niri-login
```

Two rules follow from it:

- **Duplicate detection.** Before installing, the installer scans the target
  directory and the standard ones for an existing `niri.desktop`. If it finds
  one that does not carry the marker, it assumes the distribution shipped it,
  reports that the entry already exists, and leaves it untouched. Only when no
  entry is found does it create one.
- **Safe removal.** `--remove` (and `uninstall.sh`) deletes only a file whose
  contents carry the marker. A distro-provided `niri.desktop` without the
  marker is never removed, so uninstalling this tool cannot break a
  distribution-managed session.

`--status` reports which of the two cases applies: the entry installed by this
installer, or the one provided by the distribution. It exits non-zero when no
entry is found.

## `--user` fallback caveat

`--user` (and `XDG_DATA_HOME`, defaulting to `~/.local/share`) writes to:

```
~/.local/share/wayland-sessions/niri.desktop
```

That path is **not scanned by default** by SDDM, GDM, or most other display
managers, so the entry will usually not appear at the login screen. Use
`--user` only when the display manager has been configured to include that
directory in its session search path, or for testing before a system install.
The default `--system` mode exists precisely because of this caveat.
