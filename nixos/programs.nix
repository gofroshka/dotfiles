{self, pkgs, ...}:

{
  enviroment.systemPackages = with pkgs; [
    fastfetch
    btop
  ];

}
