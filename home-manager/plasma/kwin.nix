{ ... }:

{
  programs.plasma.kwin = {
    virtualDesktops = {
      rows = 1;
      names = ["" "" "" "" "" "/" "" ""];
    };
    borderlessMaximizedWindows = true;
  };
}
