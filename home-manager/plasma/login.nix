{ ... }:

{
  programs.plasma.configFile.ksmserverrc = {
    General = {
      confirmLogout = false;
      loginMode = "restoreSavedSession";
    };
  };
}
