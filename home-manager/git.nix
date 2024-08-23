{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Artur Borysov";
    userEmail = "arthur.borisow@gmail.com";
    extraConfig = {
      core = {
        autocrlf = "input";
      };
      push = {
        default = "current";
      };
      pull = {
        rebase = true;
      };
      rerere = {
        enabled = true;
      };
      init = {
        defaultBranch = "main";
      };
      color = {
        ui = "auto";
      };
    };
    aliases = {
      ch = "checkout";
      st = "status";
      ls = "log --pretty=format:'%C(yellow)%h\ %ad%Cred%d\ %Creset%s%Cblue\ [%cn]' --decorate --date=short";
      ll = "log --pretty=format:'%C(yellow)%h%Cred%d\ %Creset%s%Cblue\ [%cn]' --decorate --numstat --date=short";
      old = "branch -r --sort=committerdate --format='[%(color:green)%(committerdate:relative)%(color:reset)] (%(authorname)) %(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject)'";
    };
    ignores = [
      "/vendor/bundle"
      "vendor/bundle"
    ];
    includes = [
      {
        condition = "gitdir/i:~/Projects/Gatekeeper/";
        path = "~/Projects/Gatekeeper/.gitconfig";
      }
      {
        condition = "gitdir/i:~/Projects/InterviewsOnline/";
        path = "~/Projects/InterviewsOnline/.gitconfig";
      }
    ];
    diff-so-fancy.enable = true;
  };
}