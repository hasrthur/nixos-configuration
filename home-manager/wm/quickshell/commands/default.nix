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
in
{
  home.packages = [
    wm-audio-output-volume
    wm-audio-input-mute
    wm-audio-input-volume
    wm-audio-output-switch
  ];
}
