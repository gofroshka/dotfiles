{
  flake.modules.nixos.base = {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
      };
    };

    networking.networkmanager.enable = true;
    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Moscow";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "ru_RU.UTF-8";
        LC_IDENTIFICATION = "ru_RU.UTF-8";
        LC_MEASUREMENT = "ru_RU.UTF-8";
        LC_MONETARY = "ru_RU.UTF-8";
        LC_NAME = "ru_RU.UTF-8";
        LC_NUMERIC = "ru_RU.UTF-8";
        LC_PAPER = "ru_RU.UTF-8";
        LC_TELEPHONE = "ru_RU.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };
  };
}
