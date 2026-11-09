{
  flake.modules.homeManager.desktop-apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      google-chrome
      telegram-desktop
      discord
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
