# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal NixOS flake for a single machine (`nixosConfigurations.nixos`, x86_64,
AMD CPU + NVIDIA GPU, **desktop — no battery, no lid, no touchpad**). Home Manager
runs as a NixOS module, not standalone. `username` and `inputs` are threaded to
every module through `specialArgs`/`extraSpecialArgs`, so modules take
`{ username, inputs, ... }` rather than importing anything.

Desktop is Hyprland under uwsm, themed by Stylix, with a hand-rolled Quickshell
shell being built out (see below).

## Applying changes

`security.sudo.wheelNeedsPassword = false` (`system/sudo.nix`), so rebuilds need
no password prompt. Run them directly; don't hand the user commands to paste.

```bash
nh os test       # activate WITHOUT creating a generation — use this while developing
nh os switch     # activate + new generation + bootloader entry — use when merging
nh os build      # build only, no activation
```

`nh os test` creates no system or Home Manager generation (Home Manager has
`useUserPackages = true`, so it has no separate user profile), which keeps
generation count sane during iteration.

**Untracked files are invisible to `nh`.** `nh os test`/`switch` evaluate the flake
git-aware, so new files must be `git add`ed (staging is enough) or they are
silently excluded — producing confusing "file not found" or stale-build errors.
`nix build --impure --expr 'builtins.getFlake "/home/artur/.nixos"'` does *not*
have this behaviour, which makes the two disagree.

## Verifying without applying

Evaluate or build a single piece rather than the whole system:

```bash
# One Home Manager package by name
nix build --impure --expr '
  let f = builtins.getFlake "/home/artur/.nixos";
  in builtins.head (builtins.filter (p: (p.name or "") == "wm-shell")
       f.nixosConfigurations.nixos.config.home-manager.users.artur.home.packages)'

# Whole HM generation (catches file collisions)
nix build '.#nixosConfigurations.nixos.config.home-manager.users.artur.home.activationPackage'

# Surface eval warnings (renamed options etc.)
nix eval --raw '.#nixosConfigurations.nixos.config.system.build.toplevel.drvPath'

# Read a resolved Stylix value
nix eval --raw '.#nixosConfigurations.nixos.config.home-manager.users.artur.lib.stylix.colors.withHashtag.base00'
```

### Hyprland config

`Hyprland --verify-config -c <file>` parses without starting a compositor. Because
`~/.config/hypr/*` are Home Manager symlinks into `/nix/store`, relative `source =`
lines fail against store paths — copy the tree first:

```bash
cp -rL ~/.config/hypr/. "$SCRATCH/v/" && chmod -R u+w "$SCRATCH/v"
```

It validates field names and structure but **not values**: `match:float notabool`
still reports `config ok`.

### Quickshell QML

`qmllint` needs Quickshell's QML dir, qtdeclarative's, and a `qs` symlink to the
built shell tree so `import qs.Commons` resolves:

```bash
mkdir -p "$LINT" && ln -s <wm-shell-qml store path> "$LINT/qs"
qmllint -I "$LINT" -I <quickshell>/lib/qt-6/qml -I <qtdeclarative>/lib/qt-6/qml <file>.qml
```

Two warnings are known false positives: `PanelWindow is not creatable` and
`DBusMenuHandle ... not found` (neither type is declared for tooling by
Quickshell). Repeater delegates reaching an outer `id` need
`pragma ComponentBehavior: Bound`.

Linting is not enough — a live run catches what it cannot. `wm-shell-launch` runs
the shell in the foreground with no supervision, deliberately, so crashes are
visible.

## Layout

- `flake.nix` — inputs: nixpkgs unstable, disko, home-manager, stylix, claude-code.
- `system/` — host config; `default.nix` is the import list. `dm/` is greetd +
  tuigreet with autologin into `uwsm start hyprland-uwsm.desktop`.
- `system/plymouth/` — a hand-built Plymouth theme (Omarchy-style passphrase entry)
  generated from Stylix colours with imagemagick/rsvg at build time.
- `home-manager/` — user config; `default.nix` is the import list.
- `home-manager/wm/` — everything desktop. `gnome/` and `plasma/` are dormant
  alternatives left in tree but not imported.

## Theming: Stylix owns everything

`system/stylix.nix` is the single source of truth (gruvbox-material-dark-hard,
CaskaydiaCove Nerd Font, Yaru icons). Nothing else defines colours or fonts.
Consumers read `config.lib.stylix.colors.withHashtag.baseXX` and
`config.stylix.fonts.*` at build time.

Consequences worth knowing:
- A theme change is a **rebuild**, everywhere. There is no runtime theme switching
  and nothing watches a colour file.
- Stylix drives `qt.platformTheme = "qtct"` and Kvantum, so Qt apps — including
  Qt *platform menus* rendered by the Quickshell tray — are coloured by
  Kvantum/qt6ct, not by the shell's own theme tokens. They will not match the bar
  exactly.
- Icons live in `/etc/profiles/per-user/artur/share/icons` (because
  `useUserPackages = true`), **not** `~/.nix-profile`.

## Hyprland config is Lua, not conf

`home-manager/wm/hyprland/` uses `configType = "lua"` with `extraLuaFiles`
(`configs/*.lua`, `configs/bindings/*.lua`). `configs/vars.lua` is shared values
and is explicitly `autoLoad = false` — modules `require("vars")` it.

**Dispatch syntax changed with Lua.** `hyprctl dispatch` wraps its argument as
`hl.dispatch(...)`, so classic dispatcher strings are a *syntax error*:

```
hyprctl dispatch "workspace 2"                        # error: ')' expected near '2'
hyprctl dispatch "hl.dsp.focus({ workspace = 2 })"    # ok
```

Not everything is a dispatcher — `hyprctl switchxkblayout current next` is its own
top-level command and must not go through dispatch.

## The Quickshell shell (in progress)

`home-manager/wm/quickshell/` is a from-scratch shell that will replace waybar,
rofi, swaync, swayosd and hyprlock. It copies **Omarchy 4's behaviour** as
inspiration; none of Omarchy's code is vendored and there is no Omarchy
dependency.

Design rules that shaped it, and should be kept:

- **No runtime configuration.** The bar layout *is* the QML. No config file, no
  plugin registry, no manifest scanning, no drag-to-rearrange — this serves one
  machine whose bar shape is known.
- **Colours are injected at build time.** `default.nix` generates
  `Commons/Theme.qml` from Stylix and assembles the QML tree with `runCommand`.
  Edit the module, never the generated file.
- **The seam.** Nothing outside the QML tree may call `qs ipc` directly; it goes
  through the `wm-shell` command. Helper commands live in a `wm-*` namespace as
  `writeShellApplication` derivations, so the drawing layer stays replaceable.
- QML modules are `qs.Commons` (Theme), `qs.Ui` (shared widgets), `qs.Widgets`
  (bar widgets), each with a `qmldir`.
- **Port Omarchy's logic and numbers, never their components.** Their `Ui/*` types
  are parameterised against their own `Style`/`Color`/`Border` singletons (which
  read a live theme and `hyprctl getoption` at runtime) and against a bar popout
  coordinator. Lifting one drags in ~1300 lines of the runtime configurability
  this shell deliberately does without. Read their file, take the ownership rules
  and the measurements, write our own.
- **Menus are drawn here, not by Qt.** `QsMenuAnchor` hands the menu to the Qt
  style, so Kvantum paints it on `window.color` (base01) and it cannot match a bar
  on base00. It also needs `//@ pragma UseQApplication` on the root file, which
  drags QtWidgets in — Omarchy sets no pragmas and never uses `QsMenuAnchor` for
  exactly this reason. `qs.Ui.Menu` renders a `QsMenuHandle` directly.
- **The waybar config is a mix of intent and workaround — ask before copying.**
  `home-manager/wm/waybar/` records what Artur wanted *and* what waybar could not
  do. Its smaller tray icons and its disabled mic scroll (`on-scroll-up: null`)
  were both compromises for waybar limitations, not preferences, and should not be
  carried over. Its glyphs, clock format, workspace icons and colour rules
  (e.g. `#pulseaudio.mic:not(.source-muted)` — red while live) are intent, and
  should be. When it is not obvious which a line is, ask.
- **Write Nerd Font glyphs as `\uXXXX` escapes, never literal characters.** Literal
  private-use codepoints do not survive every editing path and silently become
  empty strings — an empty glyph collapses a bar button to nothing, which reads as
  a missing icon rather than a bug. Verify escapes survived in the *built* store
  tree, not just the source.
- **`pactl` is not installed; only `wpctl` is.** Every Omarchy audio script is
  pactl-based, so any `wm-audio-*` port needs rewriting against wpctl/wireplumber
  (or `pulseaudio`'s client tools added).
- **PipeWire defaults are not guaranteed.** This machine has two input devices and
  no default source among them, so `Pipewire.defaultAudioSource` is null. Resolve
  through `defaultAudioSource` → `preferredDefaultAudioSource` → first non-sink
  non-stream audio node, and note that `PwNode.audio` is only populated for nodes
  held in a `PwObjectTracker`.
- **Each submenu level needs its own `QsMenuOpener`.** A child entry is owned by
  its parent opener's children model, so re-pointing one opener at the child
  destroys the entry being displayed and the submenu renders empty.

Not autostarted or supervised while it is being built out. The old stack still
runs alongside it.

## Git conventions

- **Never add a `Co-Authored-By` trailer.** No commit in this history has one.
- **Never run `git commit` unasked. Always ask first.** Propose the message in the
  reply and wait, every time, however small the change.
- Small changes go to `main`; larger multi-step work gets a branch (e.g.
  `quickshell`). Offer rather than assume.

## Dormant / intentional oddities

- `system/hybernation.nix` and `home-manager/autostart.nix` exist but are commented
  out of their import lists.
- `system/keyboard.nix` is an empty module.
- Wayland env vars are set in both `system/wayland.nix` and
  `home-manager/wm/uwsm/env`, and `uwsm/env` sets `QT_QPA_PLATFORM` twice and
  duplicates the `QT_QPA_PLATFORMTHEME` value Stylix already exports. Known, not
  yet cleaned up.
- `todo` at the repo root is Artur's own scratch list.
