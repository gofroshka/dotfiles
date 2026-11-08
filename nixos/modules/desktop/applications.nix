{
  flake.modules.homeManager.desktop-apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      firefox
      telegram-desktop
      bibata-cursors
      wf-recorder
      ffmpeg
      imagemagick
      img2pdf
      tesseract
      zbar
    ];
  };
}
