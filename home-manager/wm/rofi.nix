{ config, pkgs, lib, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
in {
  home.packages = with pkgs; [
    rofi-power-menu
  ];

  programs.rofi = {
    enable = true;
    terminal = "rofi-sensible-teminal";
    pass.enable = true;
    package = pkgs.rofi-wayland;
    theme = lib.mkMerge [{ 
      "*" = {
        margin = 0;
        padding = 0;
        spacing = 0;
      };

      window = {
        location = mkLiteral "center";
        width = 640;
        border-radius = 8;
      };

      inputbar = {
        padding = mkLiteral "12px";
        spacing = mkLiteral "12px";
        children = map mkLiteral [ "entry" ];
      };

      "entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };

      entry = {
        font = mkLiteral "inherit";

        placeholder = "Search";
      };

      message = {
        border = mkLiteral "2px 0 0";
      };

      textbox = {
        padding = mkLiteral "8px 24px";
      };

      listview = {
        lines = 10;
        columns = 1;

        fixed-height = false;
        border = mkLiteral "1px 0 0";
      };

      element = {
        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "16px";
        background-color = mkLiteral "transparent";
      };

      element-icon = {
          size = mkLiteral "1em";
      };

      element-text = {
          text-color = mkLiteral "inherit";
      };
    }];
  };
}