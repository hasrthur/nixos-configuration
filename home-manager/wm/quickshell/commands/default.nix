{ pkgs, ... }:

let
  # Audio state changes go through wpctl against WirePlumber's own graph rather
  # than pactl against the pipewire-pulse shim: the QML side already talks to that
  # graph via Quickshell.Services.Pipewire, and one model beats two.
  #
  # The shell watches PipeWire and shows the OSD on any change, including ones
  # made from outside these commands. But a keypress that changes nothing — volume
  # up at 100%, or a mute debounced away — still deserves acknowledging, so each
  # command pings the OSD when it is done. `|| true` because the shell not running
  # is not a reason for the volume key to fail.
  osdPing = "wm-shell osd show >/dev/null 2>&1 || true";

  wm-audio-output-volume = pkgs.writeShellApplication {
    name = "wm-audio-output-volume";
    runtimeInputs = [ pkgs.wireplumber ];
    text = ''
      sink=@DEFAULT_AUDIO_SINK@

      case "''${1-}" in
        raise) wpctl set-volume -l 1.0 "$sink" 5%+ ;;
        lower) wpctl set-volume "$sink" 5%- ;;
        mute-toggle)
          # Debounced: the mute key repeats readily, and a double fire is a
          # no-op that looks like the key failed. Ported from Omarchy.
          debounce="''${XDG_RUNTIME_DIR:-/tmp}/wm-audio-output-mute.last"
          now=$(date +%s%3N)
          last=0
          [ -r "$debounce" ] && read -r last < "$debounce" || true
          if [ "$((now - last))" -lt 250 ]; then
            exit 0
          fi
          printf '%s\n' "$now" > "$debounce"
          wpctl set-mute "$sink" toggle
          ;;
        +*|-*)
          step="''${1#[+-]}"
          # Setting a volume while muted should be audible, not silently staged.
          wpctl set-mute "$sink" 0
          case "$1" in
            +*) wpctl set-volume -l 1.0 "$sink" "''${step}%+" ;;
            -*) wpctl set-volume "$sink" "''${step}%-" ;;
          esac
          ;;
        *)
          echo "usage: wm-audio-output-volume <raise|lower|mute-toggle|+N|-N>" >&2
          exit 2
          ;;
      esac

      ${osdPing}
    '';
  };

  wm-audio-input-mute = pkgs.writeShellApplication {
    name = "wm-audio-input-mute";
    runtimeInputs = [ pkgs.wireplumber ];
    text = ''
      # @DEFAULT_AUDIO_SOURCE@ rather than a resolved node id: on hardware with a
      # mic-mute LED, muting through the default handle is what drives it.
      wpctl set-mute @DEFAULT_AUDIO_SOURCE@ "''${1-toggle}"

      ${osdPing}
    '';
  };

  wm-audio-input-volume = pkgs.writeShellApplication {
    name = "wm-audio-input-volume";
    runtimeInputs = [ pkgs.wireplumber ];
    text = ''
      source=@DEFAULT_AUDIO_SOURCE@

      case "''${1-}" in
        raise) wpctl set-volume -l 1.0 "$source" 5%+ ;;
        lower) wpctl set-volume "$source" 5%- ;;
        +*) wpctl set-volume -l 1.0 "$source" "''${1#+}%+" ;;
        -*) wpctl set-volume "$source" "''${1#-}%-" ;;
        *)
          echo "usage: wm-audio-input-volume <raise|lower|+N|-N>" >&2
          exit 2
          ;;
      esac

      ${osdPing}
    '';
  };

  # Cycles the default sink, the way Omarchy's Shift+Mute does. Enumeration is
  # pw-dump | jq because `wpctl status` is built for reading, not parsing.
  wm-audio-output-switch = pkgs.writeShellApplication {
    name = "wm-audio-output-switch";
    runtimeInputs = [ pkgs.wireplumber pkgs.pipewire pkgs.jq ];
    text = ''
      current=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null |
        sed -n 's/^id \([0-9]*\).*/\1/p' | head -1)

      # Sinks in graph order, skipping any whose ports are all unavailable — a
      # disconnected jack would otherwise be a silent stop on the rotation.
      mapfile -t sinks < <(pw-dump 2>/dev/null | jq -r '
        [ .[]
          | select(.type == "PipeWire:Interface:Node")
          | select(.info.props["media.class"] == "Audio/Sink")
          | select((.info.props["node.name"] // "") != "")
          | .id
        ] | .[]')

      if [ "''${#sinks[@]}" -eq 0 ]; then
        echo "no audio sinks found" >&2
        exit 1
      fi

      next=''${sinks[0]}
      for i in "''${!sinks[@]}"; do
        if [ "''${sinks[$i]}" = "$current" ]; then
          next=''${sinks[$(( (i + 1) % ''${#sinks[@]} ))]}
          break
        fi
      done

      wpctl set-default "$next"

      ${osdPing}
    '';
  };
  # Which desktop entries are hidden, respecting XDG precedence.
  #
  # Quickshell's DesktopEntries enumerates every applications directory without
  # deduplicating by desktop id, so a NoDisplay override in an earlier directory
  # does not shadow the package's own visible copy — both are yielded, and the
  # visible one shows up in the launcher. Here that means every app hidden by
  # hidden-applications.nix still appeared.
  #
  # This walks the directories in precedence order, keeps only the first file per
  # id, and prints the ids whose winning file is hidden. Ported from Omarchy's
  # shell/services/hidden-entries.sh, which exists for the same reason.
  wm-hidden-desktop-entries = pkgs.writeShellApplication {
    name = "wm-hidden-desktop-entries";
    runtimeInputs = [ pkgs.findutils pkgs.coreutils ];
    text = ''
      desktop_names="''${XDG_CURRENT_DESKTOP:-Hyprland}"

      declare -A seen

      # OnlyShowIn/NotShowIn are colon-or-semicolon separated desktop names.
      desktop_matches() {
        local list=$1 name entry
        local -a parts entries
        IFS=":" read -ra parts <<< "$desktop_names"
        IFS=";" read -ra entries <<< "$list"
        for name in "''${parts[@]}"; do
          [ -z "$name" ] && continue
          for entry in "''${entries[@]}"; do
            [ "$entry" = "$name" ] && return 0
          done
        done
        return 1
      }

      is_hidden() {
        local file=$1 in_entry=0 hidden=false only="" not="" line key value
        while IFS= read -r line || [ -n "$line" ]; do
          line=''${line%$'\r'}
          case $line in
            "["*"]")
              [ "$line" = "[Desktop Entry]" ] && in_entry=1 || in_entry=0
              continue
              ;;
          esac
          [ "$in_entry" = 1 ] || continue
          case $line in *=*) ;; *) continue ;; esac
          key=''${line%%=*}
          value=''${line#*=}
          case $key in
            Hidden|NoDisplay) [ "$value" = "true" ] && hidden=true ;;
            OnlyShowIn) only=$value ;;
            NotShowIn) not=$value ;;
          esac
        done < "$file"

        [ "$hidden" = true ] && return 0
        [ -n "$only" ] && ! desktop_matches "$only" && return 0
        [ -n "$not" ] && desktop_matches "$not" && return 0
        return 1
      }

      scan_dir() {
        local dir=$1 file id rel
        [ -d "$dir" ] || return 0
        while IFS= read -r -d "" file; do
          rel=''${file#"$dir"/}
          rel=''${rel%.desktop}
          id=''${rel//\//-}
          # First directory wins, which is what makes an override an override.
          [ -n "''${seen[$id]+set}" ] && continue
          seen[$id]=1
          # `if` rather than `&&`: under set -e a bare failing && list aborts the
          # script, so the first entry that is *not* hidden would end the scan.
          if is_hidden "$file"; then
            printf '%s\n' "$id"
          fi
        # -L because on NixOS every applications directory, and every entry in
        # it, is a symlink into the store. Omarchy's version omits it and works
        # only because Arch puts real files in /usr/share/applications.
        done < <(find -L "$dir" -type f -name '*.desktop' -print0 2>/dev/null | sort -z)
      }

      scan_dir "''${XDG_DATA_HOME:-$HOME/.local/share}/applications"

      IFS=":" read -ra dirs <<< "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      for dir in "''${dirs[@]}"; do
        scan_dir "$dir/applications"
      done
    '';
  };

  # Run a command in a floating terminal that stays open afterwards, so the
  # output of a rebuild or a generation list can actually be read. The float
  # comes from the existing terminal.float window rule.
  wm-terminal-run = pkgs.writeShellApplication {
    name = "wm-terminal-run";
    runtimeInputs = [ ];
    text = ''
      if [ "$#" -eq 0 ]; then
        echo "usage: wm-terminal-run <command> [args...]" >&2
        exit 2
      fi

      # `exec zsh` rather than exiting: a rebuild that fails should leave its
      # error on screen, not close the window it was printed in.
      exec ghostty --class=terminal.float -e zsh -c "$* ; echo ; echo '[done]' ; exec zsh"
    '';
  };

  # Focus an existing window by application identity, for click-to-jump on a
  # notification. Case-insensitive, because a sender's app_name and its window
  # class rarely agree on capitalisation (Slack notifies as "Slack", its window
  # class is "Slack"; vesktop notifies as "Vesktop", class "vesktop").
  wm-hyprland-focus-app = pkgs.writeShellApplication {
    name = "wm-hyprland-focus-app";
    runtimeInputs = [ pkgs.hyprland pkgs.jq ];
    text = ''
      app="''${1-}"
      if [ -z "$app" ]; then
        echo "usage: wm-hyprland-focus-app <app-name>" >&2
        exit 2
      fi

      address=$(hyprctl clients -j 2>/dev/null |
        jq -r --arg pattern "$app" \
          'first(.[] | select((.class // "") | test($pattern; "i"))).address // empty')

      [ -n "$address" ] || exit 1

      # The Lua config wraps dispatch, so the classic dispatcher string is a
      # syntax error there; keep it as a fallback for a non-Lua config.
      hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null 2>&1 ||
        hyprctl dispatch focuswindow "address:$address" >/dev/null
    '';
  };
in
{
  home.packages = [
    wm-hidden-desktop-entries
    wm-terminal-run
    wm-hyprland-focus-app
    wm-audio-output-volume
    wm-audio-input-mute
    wm-audio-input-volume
    wm-audio-output-switch
  ];
}
