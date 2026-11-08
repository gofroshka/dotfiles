# NixOS / Home Manager

Dendritic-конфигурация одного ноутбука **`ideapad`**, пользователь `gofroshka`.
Flake находится в `nixos/`. Других устройств или deployment-профилей NixOS нет.
Пользовательское окружение также доступно как standalone Home Manager для другого
Linux-дистрибутива; это не второй процесс применения на текущем ноутбуке.

**Миграция проверяется без активации.** Пока не выполнен переход от symlink
`~/.config` к обычному каталогу и не проверены записи загрузчика, не выполнять
`switch`, `boot` или `test`. [Результаты и ограничения миграции](docs/dendritic-migration.md).

## Структура и композиция

```text
nixos/
  flake.nix                 # явные imports flake-parts-модулей
  flake.lock                # исходный nixpkgs + pinned flake-parts и Home Manager
  hosts/ideapad/
    default.nix             # выбор NixOS-аспектов, account, greeter, boot policy
    hardware.nix            # исходный generated hardware, без изменения содержимого
    niri.kdl                # бинды яркости для backlight этого ноутбука
  users/gofroshka.nix        # общий HM-профиль и standalone output
  modules/
    core/                   # base, device-services, Home Manager и activation guard
    cli/                    # zsh, tools, zellij/config.kdl
    development/
      tools.nix
      neovim/               # default.nix, config/ (Lua), defaults/ (writable seeds)
    desktop/
      niri/                 # оба класса модулей и личные KDL в config/
      ghostty/              # default.nix и config.ghostty, без палитры dankcolors
      dms/                  # patched packages и интеграция для обоих deployment modes
      applications.nix
      librepods.nix
      qt.nix
  patches/                  # сохранённые DMS/LibrePods fixes
  certs/                    # публичный homelab CA, не private key
scripts/prepare-config-home.sh  # ручная безопасная отвязка legacy ~/.config
home/config/                # только локальные старые файлы; целиком ignored
```

Аспекты — **flake-parts-модули**, а не обычные NixOS-модули с другим названием.
`flake.nix` импортирует `inputs.flake-parts.flakeModules.modules`, регистрируя
`flake.modules`. Аспект может объявить два класса в одном файле:

```nix
{ ... }:
{
  flake.modules.nixos.example = {
    # System integration.
  };
  flake.modules.homeManager.example = {
    # Portable user configuration.
  };
}
```

В `hosts/ideapad/default.nix` явно выбираются `config.flake.modules.nixos.*`.
В `users/gofroshka.nix` явно выбираются `config.flake.modules.homeManager.*`.
Регистрация аспекта сама по себе не включает его в профиль. Автоимпорта,
feature-discovery и собственного framework нет. Generated `hardware.nix` —
намеренное исключение: обычный NixOS-модуль, импортируемый только своим хостом.

Home Manager подключён через `home-manager.nixosModules.home-manager` с
`useGlobalPkgs = true`, `useUserPackages = true`. Система и окружение пользователя
применяются одним `nixos-rebuild`. Общие HM-аспекты не используют `osConfig`,
hostname, UUID или NixOS wrappers. Различия разрешаются в композиции:

- NixOS устанавливает Niri/DMS, регистрирует login shell и системные службы;
- HM владеет пользовательскими пакетами, Zsh и выбранными статическими файлами;
- standalone composition добавляет Niri и HM-вариант DMS user service;
- только NixOS-хост добавляет свой `niri/host.kdl` с именем backlight;
- boot policy, CA, user groups и autologin находятся в host composition.

`device-services` — аспект служб питания/дисков, а не дополнительный хост.
`system.stateVersion` сохранён как `26.05`; первый `home.stateVersion` — `26.05`.
Это не версии пакетов; не повышать их вместе с обновлением inputs.

### Bluetooth

Хост `ideapad` выбирает аспект `modules/core/bluetooth.nix`: NixOS включает BlueZ
и адаптер при загрузке. Управление устройствами — через DMS или `bluetoothctl`,
без дополнительного tray applet. Звук использует уже включённые PipeWire/WirePlumber;
существующая интеграция LibrePods и её патчи сохранены. Pairing state в
`/var/lib/bluetooth/` остаётся локальным, не добавляется в Git или Nix source.

## Что воспроизводим, а что оставляем приложениям

Воспроизводим установленные программы, существующие shell preferences и четыре
набора нативных dotfiles: **Neovim, Niri, Zellij, Ghostty**. Lua/KDL не переведены в Nix.
Git/gh/LazyGit установлены через HM, но новых декларативных настроек им не навязываем.

| Файлы | Владелец |
| --- | --- |
| Nvim Lua, `init.lua`, static editor files | Home Manager, per-file links |
| Nvim `lazy-lock.json`, `lazyvim.json` | Writable: seed из `neovim/defaults/` только при отсутствии |
| Личные Niri config/binds/window rules и host fragment | Home Manager |
| `niri/dms/*.kdl` | Только DMS; HM не создаёт и не меняет эти файлы |
| `ghostty/config.ghostty`, `zellij/config.kdl` | Home Manager |
| `ghostty/themes/dankcolors` | DMS; при первом запуске только пустой writable placeholder |
| Обои, monitors, виджеты, DMS settings, GTK/Qt colors и прочие GUI preferences | Приложения; не Git и не HM |
| Profiles, auth tokens, pairing keys, dconf, caches | Только локальное runtime state |

First-run шаблонов и seed hooks для Niri нет: генерируемыми includes целиком
управляет DMS. Они подключены с `optional=true`: отсутствующий файл не мешает
первому запуску, существующий читается как обычно и проверяется на ошибки.
Существующие runtime-файлы при rebuild не удаляются. Seed hooks
Neovim/Ghostty ничего не перезаписывают, в том числе symlinks. Бинды яркости с
`amdgpu_bl1` вынесены в хост. Ghostty использует `working-directory = home`,
не имя конкретного пользователя.

LazyVim продолжает управлять своими plugins: второго plugin manager нет.
Начальный plugin lock закреплён в Git, но обновления активного lock остаются
локальными. Чтобы сделать новое состояние bootstrap-default, явно перенесите
проверенный lock из `~/.config/nvim/lazy-lock.json` в `neovim/defaults/` и проверьте diff.
Не ожидайте, что откат NixOS откатит mutable state или загруженные plugins.
Статические конфиги редактировать в исходниках соответствующего аспекта, затем
пересобирать профиль: установленные HM-ссылки ведут в read-only Nix store.

## Проверки и сборки без применения

Все команды ниже — из корня репозитория:

```sh
nix flake show --no-write-lock-file ./nixos
nix flake check --no-write-lock-file ./nixos
nixos-rebuild build --flake ./nixos#ideapad
nix build --no-link './nixos#homeConfigurations."gofroshka@linux".activationPackage'
nix build --no-link ./nixos#nixosConfigurations.ideapad.config.home-manager.users.gofroshka.home.activationPackage
```

Собственных `checks` нет. `flake check` проверяет NixOS output, но не заменяет
явные сборки системы и обоих HM activation packages командами выше.
Реальная активация при этих проверках не запускается.
Предупреждение Nix `unknown flake output 'modules'` нормально: это документированный
дополнительный output flake-parts, который сам CLI Nix пока не распознаёт.

Git flakes не включают неотслеживаемые файлы. Добавляйте только выбранные новые
source paths в index перед проверкой, не `git add .` в дереве с пользовательскими
изменениями. Не используйте `path:` flake source для обхода Git-фильтра: так можно
включить ignored runtime credentials. `git clean -fdx` здесь также недопустим.

## Первый переход текущего ноутбука на Home Manager

**Не выполнялось автоматически.** Нужны отдельное разрешение на применение,
TTY/закрытые приложения и проверенный backup важных данных. HM откажется
линковать dotfiles, пока корень `~/.config` является symlink: это защищает рабочий
репозиторий, но не откатывает другие части потенциально частичного system switch.

1. Проверить `lsblk -f`, `findmnt --real`, `/etc/fstab` и host hardware.
2. Проверить от root `bootctl list --no-pager`, записи и initrd в `/boot`.
   Проверенное старое поколение должно оставаться доступным в systemd-boot.
3. Сохранён recovery GC root
   `~/.local/state/nixos-migration/gofronix-working`, указывающий на рабочее
   поколение до миграции и переименования хоста. Имя этого recovery root сохранено
   намеренно. Он защищает store closure, **но не гарантирует**
   сохранение ESP-записи. Не удалять root или поколения до проверки загрузки.
   Существующая политика daily GC старше 3 дней не менялась; перед будущими
   очистками отдельно решить retention загрузочных поколений.
4. После отдельного решения выполнить вручную:

   ```sh
   bash scripts/prepare-config-home.sh
   ```

   Скрипт копирует всю живую конфигурацию, включая mutable state, в обычный
   `~/.config`, сохраняет прежнюю ссылку в
   `~/.local/state/nixos-migration/config-backup.*/config-root.link`, исходный
   каталог не меняет. Не запускает rebuild или HM. Не выполнять при работающих
   приложениях, которые одновременно записывают конфиги.
5. Повторить build/check и только затем разрешённое применение:

   ```sh
   sudo nixos-rebuild switch --flake ./nixos#ideapad
   ```

   HM использует backup extension `.before-home-manager` для конфликтующих
   статических файлов. Существующий backup не перезаписывается: нужно остановиться
   и разобраться. Генерируемые DMS-файлы и Neovim JSON seeds под эту замену не попадают.
6. Проверить HM service, вход в сессию, Niri binds, терминал, editor и перезагрузку.
   Команды диагностики: `systemctl status home-manager-gofroshka.service`,
   `journalctl -u home-manager-gofroshka.service -b`,
   `systemctl --user status dms.service`.

На NixOS не выполнять standalone `home-manager switch` для этого пользователя.
Standalone output содержит собственную защиту от активации при наличии `/etc/NIXOS`.

## Standalone Home Manager на другом Linux

Нужны установленный Nix с flakes, пользователь `gofroshka`, его home (при другом
пути измените identity в `users/gofroshka.nix`), рабочий systemd user session и
графическая инфраструктура дистрибутива. Drivers, display/login manager, PipeWire,
portals, polkit, permissions для brightness/screen capture и session integration
не становятся задачей Home Manager. Не переиспользовать NixOS hardware на другом Linux.

Сначала собрать output командой выше. Для разрешённой первой активации можно
запустить CLI из **закреплённого input**, не случайную версию из registry:

```sh
nix run --inputs-from ./nixos home-manager -- -b before-home-manager switch --flake './nixos#gofroshka@linux'
```

После этого доступен `home-manager`:

```sh
home-manager -b before-home-manager switch --flake './nixos#gofroshka@linux'
```

Если нужен Niri desktop, графический login/session manager дистрибутива должен
запускать Niri session и правильно импортировать Wayland окружение в systemd user
manager. Сборка на NixOS проверена; запуск desktop на другом дистрибутиве не тестировался.
CLI/editor/terminal-конфиги общие, а NixOS-specific LibrePods wrappers не импортируются.

## Новая фича

1. Создать `nixos/modules/<area>/<feature>/default.nix`; native config положить рядом.
2. Объявить `flake.modules.nixos.<feature>` и/или `.homeManager.<feature>`.
   Не добавлять собственный `enable`, если достаточно явного импорта аспекта.
3. Добавить flake-parts-модуль в `nixos/flake.nix`.
4. Выбрать нужный класс в host/user imports. HM-аспект не должен зависеть от
   `osConfig`, другого дистрибутива или чужого home path.
5. Убедиться, что пакет/файл не имеет второго владельца. Для изменяемого GUI state
   не создавать store symlink. Явно собрать оба HM activation packages и систему.

## Новый ноутбук/хост и минимальный bootstrap

Сейчас существует только `ideapad`. Новые устройства добавляются явно:

1. Установить минимальную NixOS обычным способом и проверить загрузку/интернет.
2. Получить доступ к приватному Git через SSH key/agent или credential helper.
   Не помещать токены в clone URL, историю shell или Nix input URLs.
3. Клонировать репозиторий. Не копировать старый `~/.config` целиком и не создавать
   ссылку на `home/config/`. HM установит выбранные config sources.
4. Создать `hosts/NEW/default.nix` по структуре host composition. Скопировать
   **с новой машины** `/etc/nixos/hardware-configuration.nix` как её `hardware.nix`.
5. Вписать явные hostname, account/home/groups, исходный `system.stateVersion`
   установленной машины и её прежнюю boot policy. Проверить, нужен ли homelab CA
   и autologin; не переносить их автоматически. Выбрать существующие аспекты.
6. Добавить новый host module в imports `flake.nix`. Для backlight использовать
   его фактическое устройство в host KDL либо оставить пустой portable fragment.
7. Сопоставить `lsblk -f`, `findmnt`, `/etc/fstab` и evaluated `fileSystems`,
   `swapDevices`, initrd/LUKS/kernel/bootloader. Чужие UUID/subvolumes не использовать.
8. Проверить `flake show/check`, собрать `nixos-rebuild build --flake ./nixos#NEW`.
   Сохранить старое поколение и проверить ESP до отдельного разрешения на switch.
9. Выполнить согласованную активацию, проверить реальную загрузку и только затем
   зафиксировать корректную host-specific конфигурацию в Git.

Ни форматирование, ни Disko, ни nixos-anywhere для этого процесса не нужны.
Архитектура допускает добавить их позже, если появится конкретная необходимость.

## Восстановление

- После неудачного rebuild без activation рабочая система не меняется.
- После неудачной загрузки выбрать проверенное предыдущее поколение в systemd-boot.
  После входа разобраться с причиной и лишь затем согласовать rollback/switch.
- Не делать `git reset --hard`: исходный Git HEAD содержит UUID прежней установки.
  Текущий hardware перенесён в host directory с сохранением содержимого.
- Если загрузчик недоступен, использовать установочный носитель. Сначала проверить
  реальные устройства и Btrfs subvolumes; mount/repair делать по фактическому layout
  без форматирования и без чужого hardware. Исправлять причину, не менять boot stack.
- Для отката ручной отвязки `~/.config` сохранить новый каталог под другим именем
  и вернуть `config-root.link` из backup. Не перетирать ни новый, ни старый каталог.
  После первого HM deployment учитывать также per-file `.before-home-manager` backups.
- NixOS rollback не возвращает обои, runtime JSON, plugin downloads, tokens и прочее
  mutable state; для важных данных нужен обычный backup.

## Секреты и legacy DMS plugins

Runtime auth (`gh/`, `opencode/service.json`, `pulse/cookie`, AirPods pairing keys,
DMS Home Assistant token) не является config source. Вводить/создавать их через
приложения локально. Приватный репозиторий не делает Nix store закрытым: tracked
файлы из всего Git tree могут попасть в source snapshot даже с flake в подкаталоге.
При добавлении новых source files проверять их на credentials; public CA допустим,
private keys — нет. Старые commits/store snapshots содержали authentication files:
нужна отдельная ротация, очистка текущего дерева не удаляет историю.

Legacy `.gitmodules` и записи plugins в старом `home/config/dms/plugins/` не являются
частью новой HM-композиции. Во время работы обнаружены их внешние удаления; они не
восстанавливались и не были включены в этот рефакторинг. Нужные DMS plugins можно
установить заново через DMS; личные Quick Capture binds требуют соответствующего
plugin. Их наличие/настройки не гарантируются новым чистым home.
