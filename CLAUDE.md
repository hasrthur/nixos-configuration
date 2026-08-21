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

`home-manager/wm/quickshell/` is a from-scratch shell replacing the old desktop
stack piece by piece. It copies **Omarchy 4's behaviour** as inspiration; none of
Omarchy's code is vendored and there is no Omarchy dependency.

**Done:** the bar (workspaces, clock, privacy, tray, keyboard layout, bluetooth,
network, audio, microphone, cpu) and the tray menu. **waybar is retired.**
**Still to replace:** swayosd, swaync, rofi-as-launcher, bzmenu/pwmenu/nm-applet,
cliphist, hyprpolkitagent, hyprlock and hypridle.

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
- **The retired waybar config is still the reference for intent — but it mixes
  intent with workaround.** It now lives only in git history:
  `git show b63e0da^:home-manager/wm/waybar/config.jsonc` (and `style.css`). Its
  glyphs, clock format, workspace icons, spacing and colour rules
  (e.g. `#pulseaudio.mic:not(.source-muted)` — red while live) are intent. Its
  smaller tray icons and disabled mic scroll (`on-scroll-up: null`) were
  compromises for waybar limitations, not preferences, and were deliberately not
  carried over. When it is not obvious which a line is, ask.
- **Verify a glyph's codepoint against the font before using it.** Existing in the
  font is not the same as being the right icon: the privacy indicator first used
  U+F03B0, which is `md-numeric_5_box_outline`, so it drew a literal "5". Only
  glyphs copied from a known-good config are safe unchecked. Codepoints above the
  BMP need surrogate pairs (Omarchy does the same).

  ```bash
  P=$(nix build --no-link --print-out-paths 'nixpkgs#python3Packages.fonttools')
  PYTHONPATH=$(echo $P/lib/python3*/site-packages) python3 -c '
  from fontTools.ttLib import TTFont
  cmap = TTFont("<font.ttf>").getBestCmap()
  print(cmap.get(0xF1483))   # -> md-monitor_share
  '
  ```
- **Write Nerd Font glyphs as `\uXXXX` escapes, never literal characters.** Literal
  private-use codepoints do not survive every editing path and silently become
  empty strings — an empty glyph collapses a bar button to nothing, which reads as
  a missing icon rather than a bug. Verify escapes survived in the *built* store
  tree, not just the source.
- **Audio CLI stays native: `wpctl` for state, `pw-dump | jq` for enumeration.**
  No `pactl`, so no `pkgs.pulseaudio` — the pipewire-pulse shim's client is a
  supported tool but a layer removed from the graph the QML side already talks to
  via `Quickshell.Services.Pipewire`.

  Omarchy uses both (pactl 29 call sites, wpctl 7), split by task: `wpctl` for
  `set-default`, mute and `@DEFAULT_AUDIO_SOURCE@` handles (which drive the
  hardware mic-mute LED), `pactl -f json` for machine-readable listings that
  `wpctl status` cannot give. Porting those listings means `pw-dump | jq` here.

  Worth knowing before assuming a units mismatch: their own comment notes `pactl`
  and `wpctl` report the *same* percentage scale (both raw volume over
  `PA_VOLUME_NORM`). Volume numbers are interchangeable; it is the graph model that
  differs.

  Swapping one tool for another is not a showstopper for Artur in general — say so
  and propose it rather than contorting around a missing tool.
- **PipeWire defaults are not guaranteed.** This machine has two input devices and
  no default source among them, so `Pipewire.defaultAudioSource` is null. Resolve
  through `defaultAudioSource` → `preferredDefaultAudioSource` → first non-sink
  non-stream audio node, and note that `PwNode.audio` is only populated for nodes
  held in a `PwObjectTracker`.
- **Each submenu level needs its own `QsMenuOpener`.** A child entry is owned by
  its parent opener's children model, so re-pointing one opener at the child
  destroys the entry being displayed and the submenu renders empty.

It autostarts from `hyprland/configs/execs.lua` under `uwsm app`, so its output
reaches the journal (`journalctl --user -b | grep -i quickshell`). Deliberately
**unsupervised**: a crash should be visible rather than silently relaunched, and
`wm-shell-launch` restarts it by hand. Since waybar is gone, a crash means no bar.

## Git conventions

- **Never add a `Co-Authored-By` trailer.** No commit in this history has one.
- **Never run `git commit` unasked. Always ask first.** Propose the message in the
  reply and wait, every time, however small the change.
- Small changes go to `main`; larger multi-step work gets a branch (e.g.
  `quickshell`). Offer rather than assume.
- **Merge branches with `--no-ff`, never `--ff-only`.** Artur wants a merge commit
  even when a fast-forward is possible, so the branch's commits stay visible as a
  unit. Do not infer "linear history" from the fact that older commits happen to
  be linear.
- **One branch per topic; merge it when the topic is done.** Do not keep building
  the next piece of work on a finished branch — the name stops describing the
  contents, and the merge commit stops meaning anything. Merge, then branch fresh.

## Dormant / intentional oddities

- `system/hybernation.nix` and `home-manager/autostart.nix` exist but are commented
  out of their import lists.
- `system/keyboard.nix` is an empty module.
- Wayland env vars are set in both `system/wayland.nix` and
  `home-manager/wm/uwsm/env`, and `uwsm/env` sets `QT_QPA_PLATFORM` twice and
  duplicates the `QT_QPA_PLATFORMTHEME` value Stylix already exports. Known, not
  yet cleaned up.
- `todo` at the repo root is Artur's own scratch list.
