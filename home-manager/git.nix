{ ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = null;
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Artur Borysov";
        email = "arthur.borisow@gmail.com";
      };
      core.autocrlf = "input";
      push.default = "simple";
      pull.rebase = true;
      rerere.enabled = true;
      init.defaultBranch = "main";
      color.ui = "auto";
      alias = {
        ch = "checkout";
        st = "status";
        ls = "log --pretty=format:'%C(yellow)%h\ %ad%Cred%d\ %Creset%s%Cblue\ [%cn]' --decorate --date=short";
        ll = "log --pretty=format:'%C(yellow)%h%Cred%d\ %Creset%s%Cblue\ [%cn]' --decorate --numstat --date=short";
        old = "branch -r --sort=committerdate --format='[%(color:green)%(committerdate:relative)%(color:reset)] (%(authorname)) %(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject)'";
      };
    };
    ignores = [
      "/.idea"
    ];
  };
  programs.diff-so-fancy.enable = true;
}
