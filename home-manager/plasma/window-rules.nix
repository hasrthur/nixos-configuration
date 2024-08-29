{ ... }:

{
  programs.plasma.configFile.kwinrc = {
    Desktops = {
      Id_1 = "fa58a73b-0f0b-4ec8-857c-ee536024ae18";
      Id_2 = "fdfcc310-9f0b-4413-b907-42b660756eaa";
      Id_3 = "b2c7334a-bb82-49e7-a4fd-37780ad281ce";
      Id_4 = "a631021e-e1e8-43f8-810f-4aa7e291686d";
      Id_5 = "866f6d9d-11e7-40c1-baaf-fa5392d9be0a";
      Id_6 = "96a386b7-1daa-43f2-930d-9f623d8ff9d0";
      Id_7 = "0669f7fb-a5bb-4098-85a9-de5b4293ff9e";
      Id_8 = "b31becd4-b4d4-4a2f-82e3-1fc8a390289d";
    };
  };

  programs.plasma.window-rules = [
    {
      description = "Kitty";
      match.window-class = "kitty kitty";
      apply = {
        desktops = "fa58a73b-0f0b-4ec8-857c-ee536024ae18";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
    {
      description = "Visual Studio Code";
      match.window-class = "code code-url-handler";
      apply = {
        desktops = "fdfcc310-9f0b-4413-b907-42b660756eaa";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
    {
      description = "Chromium";
      match.window-class = "chromium chromium-browser";
      apply = {
        desktops = "b2c7334a-bb82-49e7-a4fd-37780ad281ce";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
    {
      description = "Slack";
      match.window-class = "slack Slack";
      apply = {
        desktops = "a631021e-e1e8-43f8-810f-4aa7e291686d";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
    {
      description = "Discord";
      match.window-class = "electron vesktop";
      apply = {
        desktops = "866f6d9d-11e7-40c1-baaf-fa5392d9be0a";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
    {
      description = "Thunderbird";
      match.window-class = "thunderbird thunderbird";
      apply = {
        desktops = "0669f7fb-a5bb-4098-85a9-de5b4293ff9e";
        maximizehoriz = true;
        maximizevert = true;
        noborder = true;
      };
    }
  ];
}
