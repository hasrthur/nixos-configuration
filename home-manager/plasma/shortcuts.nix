{ ... }:

{
  programs = {
    plasma = {
      shortcuts = {
        kwin = {
          "Switch to Desktop 1" = "Meta+1";
          "Switch to Desktop 2" = "Meta+2";
          "Switch to Desktop 3" = "Meta+3";
          "Switch to Desktop 4" = "Meta+4";
          "Switch to Desktop 5" = "Meta+5";
          "Switch to Desktop 6" = "Meta+6";
          "Switch to Desktop 7" = "Meta+7";
          "Switch to Desktop 8" = "Meta+8";
          "Switch to Desktop 9" = "Meta+9";
          "Switch to Desktop 10" = "Meta+0";

          "Switch to Next Desktop" = "Meta+L";
          "Switch to Previous Desktop" = "Meta+H";

          "Window to Desktop 1" = "Meta+!";
          "Window to Desktop 2" = "Meta+@";
          "Window to Desktop 3" = "Meta+#";
          "Window to Desktop 4" = "Meta+$";
          "Window to Desktop 5" = "Meta+%";
          "Window to Desktop 6" = "Meta+^";
          "Window to Desktop 7" = "Meta+&";
          "Window to Desktop 8" = "Meta+*";
          "Window to Desktop 9" = "Meta+(";
          "Window to Desktop 10" = "Meta+)";

          "Window Close" = "Meta+Shift+Q";
        };

        "services/org.kde.krunner.desktop"."_launch" = "Meta+Space";
      };
    };
  };
}
