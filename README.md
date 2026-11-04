# Dotfiles

NixOS configuration: `nixos/flake.nix`, host `gofronix`.
Desktop configuration lives in `home/config/`.

```sh
git submodule update --init --recursive
sudo nixos-rebuild switch --flake ./nixos#gofronix
```

## Local secrets

These runtime files are intentionally ignored and must remain writable:

- `home/config/AirPodsTrayApp/AirPodsTrayApp.conf` contains AirPods pairing keys.
- `home/config/dms/plugin_settings.json` contains the Home Assistant access token.
- `home/config/gh/` may contain GitHub authentication credentials.

On a new installation, copy the corresponding `.example` files to the real names
only if the real files do not already exist. Fill in the Home Assistant token
locally and let LibrePods create pairing keys when connecting the headphones.
Do not overwrite existing live configs with the examples.

Removing secrets from the current tree does not remove them from old commits.
Previously committed credentials should be rotated; rewriting history is a separate operation.

## Local plugin versions

The plugin Git submodules pin the tested versions, including:

- AirPods refactor and bar fixes: https://github.com/demic-dev/airpods-widget-DMS/pull/1
- Quick Capture menu fix: https://github.com/hthienloc/dms-plugins/pull/38

The local Quick Capture snapshot also retains the nested-QML cache workaround.
The NixOS DMS patch makes Control Center visibility honor the AirPods plugin's
independent setting without removing its saved placement.
