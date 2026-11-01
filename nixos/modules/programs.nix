{self, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    btop
  ];

}
