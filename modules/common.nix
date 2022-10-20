{ pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.dstat
    pkgs.htop
    pkgs.tmux
  ];
}
