{ pkgs, ... }:

{
  xdg.configFile = {
    "autostart/chromium-browser.desktop".source = "${pkgs.chromium}/share/applications/chromium-browser.desktop";
    "autostart/slack.desktop".source = "${pkgs.slack}/share/applications/slack.desktop";
    "autostart/code.desktop".source = "${pkgs.vscode-fhs}/share/applications/code.desktop";
    "autostart/birdtray.desktop".source = "${pkgs.birdtray}/share/applications/com.ulduzsoft.Birdtray.desktop";
    "autostart/thunderbird.desktop".source = "${pkgs.thunderbird}/share/applications/thunderbird.desktop";
    "autostart/vesktop.desktop".source = "${pkgs.vesktop}/share/applications/vesktop.desktop";
    "autostart/kitty.desktop".source = "${pkgs.kitty}/share/applications/kitty.desktop";
  };
}
