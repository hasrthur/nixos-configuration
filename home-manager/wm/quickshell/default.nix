{ config, pkgs, ... }:

let
  inherit (config.lib.stylix) colors;

  fonts = config.stylix.fonts;

  # The shell's entire visual vocabulary, resolved from Stylix at build time.
  # There is no runtime theme layer and nothing watches a colour file: changing
  # the theme is a rebuild, exactly as it is for every other themed thing here.
  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton

    import QtQuick

    // Generated from Stylix by home-manager/wm/quickshell/default.nix.
    // Edit that module, not this file.
    QtObject {
        readonly property color background: "${colors.withHashtag.base00}"
        readonly property color surface: "${colors.withHashtag.base01}"
        readonly property color overlay: "${colors.withHashtag.base02}"
        readonly property color muted: "${colors.withHashtag.base03}"
        readonly property color foreground: "${colors.withHashtag.base05}"
        readonly property color emphasis: "${colors.withHashtag.base07}"

        readonly property color urgent: "${colors.withHashtag.base08}"
        readonly property color warning: "${colors.withHashtag.base0A}"
        readonly property color success: "${colors.withHashtag.base0B}"
        readonly property color accent: "${colors.withHashtag.base0D}"

        readonly property color barBackground: "${colors.withHashtag.base00}"

        // Mutable shell state. The only thing this shell writes.
        readonly property string stateDir: "${config.xdg.stateHome}/wm"

        readonly property string fontFamily: "${fonts.monospace.name}"
        readonly property int fontSize: ${toString fonts.sizes.popups}

        readonly property int barHeight: 34
        // Matches a size the icon themes actually ship (16/22/32), so nothing
        // is upscaled.
        readonly property int trayIconSize: 22
        readonly property color menuBackground: "${colors.withHashtag.base00}"
        readonly property color menuBorder: "${colors.withHashtag.base02}"
        readonly property color menuHighlight: "${colors.withHashtag.base02}"

        // Mirrors decoration.rounding in home-manager/wm/hyprland/hypr.lua, so
        // popups are shaped like windows.
        readonly property int menuRadius: 5
        readonly property int menuBorderWidth: 2
        readonly property int menuPadding: 14
        readonly property int menuRowHeight: 30
        readonly property int menuSeparatorHeight: 11
        readonly property int menuIconSize: 16
        // Distance between the bar and a popup hanging off it.
        readonly property int menuGap: 5

        // Omarchy's indicators are caption-sized in a fixed slot, so the cluster
        // does not reflow as modes come and go.
        readonly property int indicatorSlot: 22
        readonly property int indicatorFontSize: 11

        readonly property int launcherWidth: 620
        readonly property int launcherTopMargin: 140
        readonly property int launcherRowHeight: 34
        readonly property int launcherMaxRows: 12
        readonly property int launcherIconWidth: 28
        readonly property int launcherAppIconSize: 22

        readonly property int notificationWidth: 380
        readonly property int notificationIconSize: 32

        readonly property int osdMargin: 120
        readonly property int osdPadding: 16
        readonly property int osdGap: 16
        readonly property int osdIconWidth: 28
        readonly property int osdBarWidth: 142
        readonly property int osdReadoutWidth: 46
        // waybar set the bar's own spacing to 0 and let each module's margin do
        // the work (~7.5px a side, so ~15px between glyphs), with 8px at the bar
        // edges. Match that: the visible gap here is BarButton's horizontal
        // padding twice over (2 x 8 = 16), not an extra gap on top of it.
        readonly property int edgeGap: 8
        readonly property int widgetGap: 0
    }
  '';

  # The menu tree, generated from menu.nix. Same pattern as Theme: authored in
  # Nix, baked into QML at build time, never read at runtime.
  menuQml = pkgs.writeText "MenuTree.qml" ''
    pragma Singleton

    import QtQuick

    // Generated from home-manager/wm/quickshell/menu.nix.
    // Edit that file, not this one.
    QtObject {
        readonly property var routes: ${builtins.toJSON (import ./menu.nix)}
    }
  '';

  shell = pkgs.runCommand "wm-shell-qml" { } ''
    mkdir -p $out
    cp -r ${./qml}/. $out/
    chmod -R u+w $out
    install -m444 ${themeQml} $out/Commons/Theme.qml
    install -m444 ${menuQml} $out/Commons/MenuTree.qml
  '';

  # The seam. Nothing outside the QML tree may call `qs ipc` directly, so that
  # replacing what draws the pixels stays a change to this file alone.
  wm-shell = pkgs.writeShellApplication {
    name = "wm-shell";
    runtimeInputs = [ pkgs.quickshell ];
    text = ''
      if [ "$#" -lt 2 ]; then
        echo "usage: wm-shell <target> <method> [args...]" >&2
        exit 2
      fi

      exec qs ipc -p ${shell} call -- "$@"
    '';
  };

  # No supervision and no relaunch loop, on purpose: while the shell is still
  # being built out, a crash should be visible rather than papered over.
  wm-shell-launch = pkgs.writeShellApplication {
    name = "wm-shell-launch";
    runtimeInputs = [ pkgs.quickshell ];
    text = ''
      exec qs -p ${shell} "$@"
    '';
  };
in
{
  imports = [ ./commands ];

  # FileView will not create the directory it writes into.
  home.file."${config.xdg.stateHome}/wm/.keep".text = "";

  home.packages = [
    pkgs.quickshell
    wm-shell
    wm-shell-launch
  ];
}
