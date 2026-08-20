{ pkgs, config, ... }:

let
  inherit (config.lib.stylix) colors;

  themeName = "nix-omarchy";

  background = with colors; "${base00-dec-r}, ${base00-dec-g}, ${base00-dec-b}";
  foreground = colors.withHashtag.base05;

  # Rendered size of the snowflake. The transparent border keeps the corners
  # from being clipped while the logo spins.
  logoSize = 256;
  logoBorder = 42; # percent

  # Passphrase field geometry, matching the Omarchy theme.
  entryWidth = 286;
  entryHeight = 48;
  entryGap = 40; # vertical distance between the logo and the field
  lockGap = 15; # horizontal distance between the lock and the field
  bulletSize = 7;
  bulletGap = 5;
  bulletInset = 20;
  maxBullets = 21;

  themeScript = pkgs.replaceVars ./theme.script {
    inherit background;
    logoRadius = toString (logoSize / 2);
    entryGap = toString entryGap;
    lockGap = toString lockGap;
    bulletSize = toString bulletSize;
    bulletGap = toString bulletGap;
    bulletInset = toString bulletInset;
    maxBullets = toString maxBullets;
  };

  theme = pkgs.runCommand "plymouth-theme-${themeName}"
    {
      nativeBuildInputs = [
        pkgs.imagemagick
        pkgs.librsvg
      ];
    }
    ''
      dir="$out/share/plymouth/themes/${themeName}"
      mkdir -p "$dir"

      magick \
        -background transparent \
        -bordercolor transparent \
        ${pkgs.nixos-icons}/share/icons/hicolor/512x512/apps/nix-snowflake.png \
        -resize ${toString logoSize}x${toString logoSize} \
        -border ${toString logoBorder}% \
        "$dir/logo.png"

      rsvg-convert -o "$dir/entry.png" <<'EOF'
      <svg xmlns="http://www.w3.org/2000/svg" width="${toString entryWidth}" height="${toString entryHeight}">
        <rect x="0.5" y="0.5" width="${toString (entryWidth - 1)}" height="${toString (entryHeight - 1)}" rx="3"
              fill="#000000" fill-opacity="0.05"
              stroke="${foreground}" stroke-opacity="0.58" stroke-width="1"/>
      </svg>
      EOF

      rsvg-convert -o "$dir/lock.png" <<'EOF'
      <svg xmlns="http://www.w3.org/2000/svg" width="84" height="96">
        <path d="M24 42 V25 a18 18 0 0 1 36 0 V42"
              fill="none" stroke="${foreground}" stroke-width="12"/>
        <mask id="keyhole">
          <rect width="84" height="96" fill="white"/>
          <rect x="35" y="54" width="14" height="26" rx="7" fill="black"/>
        </mask>
        <rect x="0" y="36" width="84" height="60" rx="10"
              fill="${foreground}" mask="url(#keyhole)"/>
      </svg>
      EOF

      rsvg-convert -o "$dir/bullet.png" <<'EOF'
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14">
        <circle cx="7" cy="7" r="7" fill="${foreground}"/>
      </svg>
      EOF

      cp ${themeScript} "$dir/${themeName}.script"

      cat > "$dir/${themeName}.plymouth" <<EOF
      [Plymouth Theme]
      Name=NixOS
      ModuleName=script

      [script]
      ImageDir=$dir
      ScriptFile=$dir/${themeName}.script
      EOF
    '';
in
{
  # Superseded by the theme below, which keeps the Stylix colours and logo but
  # drops the passphrase prompt text.
  stylix.targets.plymouth.enable = false;

  boot.plymouth = {
    enable = true;
    theme = themeName;
    themePackages = [ theme ];
    extraConfig = ''
      DeviceTimeout=0
    '';
  };
}
