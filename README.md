# pimp-my-windows

**[English](#english)** · **[Українська](#українська)**

Personal Windows 11 setup — a minimalist dark + blue theme. Backup & restore of all my configs, so I can rebuild the whole environment after a clean install.

---

## English

### What this is

A backup / restore system for my customized Windows setup:

- **Windows Terminal** — graphite background + transparency, custom "Night Blue" color scheme
- **PowerShell 7 + Oh My Posh** — custom blue "amro" prompt
- **Flow Launcher** — Darker Glass theme + plugins
- **Windhawk** — taskbar + File Explorer mods
- **StartAllBack** — classic Start menu
- **Accent color** — `#3D5A80` (night blue)

### Structure

```
backup.ps1     collects configs from the current system into ./configs
restore.ps1    deploys everything on a fresh install (run as Administrator)
configs/       the saved config files
.gitignore     keeps secrets / cache out of git
```

### How to back up (on the current system)

```powershell
.\backup.ps1
git add .
git commit -m "update configs"
git push
```

### How to restore (on a fresh Windows install)

1. Install git, then clone the repo:

   ```powershell
   git clone https://github.com/Yareli0i/pimp-my-windows.git
   cd pimp-my-windows
   ```

2. Allow scripts to run (once):

   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

3. Run restore **as Administrator**:

   ```powershell
   .\restore.ps1
   ```

4. Follow the manual checklist it prints at the end.

### Manual steps (not automated)

- **Restart** after restore (so StartAllBack + accent color apply)
- **Windhawk mods** — verify / reinstall (they depend on the Windows build):
  - Taskbar Styler (theme: SimplyTransparent)
  - Taskbar Background Helper
  - File Explorer Styler (theme: Minimal Explorer11)
- **StartAllBack** — only the Start Menu section should be ON (Taskbar + Explorer sections OFF — those are handled by Windhawk)
- **Flow plugins** — reinstall from `configs/flow/installed-plugins.txt`, then re-login to the Spotify / Steam plugins
- **Terminal** — set PowerShell 7 as the default profile + Windows Terminal as the default terminal app
- **Wallpapers** — set up manually in Wallpaper Engine

### Security note

Tokens and caches are **not** backed up (see `.gitignore`). The Spotify / Steam plugins need re-login after a restore.

---

## Українська

### Що це

Система резервного копіювання та відновлення моїх налаштувань Windows:

- **Windows Terminal** — графітовий фон + прозорість, власна схема "Night Blue"
- **PowerShell 7 + Oh My Posh** — синій промпт "amro"
- **Flow Launcher** — тема Darker Glass + плагіни
- **Windhawk** — моди таскбару та провідника
- **StartAllBack** — класичне меню Пуск
- **Акцентний колір** — `#3D5A80` (нічний синій)

### Структура

```
backup.ps1     збирає конфіги з поточної системи в ./configs
restore.ps1    розгортає все на чистій системі (запуск від Адміністратора)
configs/       збережені файли конфігів
.gitignore     не пускає секрети / кеш у git
```

### Як зробити резервну копію (на поточній системі)

```powershell
.\backup.ps1
git add .
git commit -m "update configs"
git push
```

### Як відновити (на свіжовстановленій Windows)

1. Встанови git, потім клонуй репозиторій:

   ```powershell
   git clone https://github.com/Yareli0i/pimp-my-windows.git
   cd pimp-my-windows
   ```

2. Дозволь виконання скриптів (один раз):

   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

3. Запусти restore **від імені Адміністратора**:

   ```powershell
   .\restore.ps1
   ```

4. Виконай чекліст ручних кроків, який скрипт виведе наприкінці.

### Ручні кроки (не автоматизовані)

- **Перезавантаж** після відновлення (щоб StartAllBack + акцентний колір застосувались)
- **Моди Windhawk** — перевір / перевстанови (залежать від білда Windows):
  - Taskbar Styler (тема: SimplyTransparent)
  - Taskbar Background Helper
  - File Explorer Styler (тема: Minimal Explorer11)
- **StartAllBack** — має бути увімкнена ТІЛЬКИ секція "Меню Пуск" (секції Таскбар + Провідник ВИМКНЕНІ — це Windhawk)
- **Плагіни Flow** — перевстанови зі списку `configs/flow/installed-plugins.txt`, потім перелогінься у плагінах Spotify / Steam
- **Термінал** — постав PowerShell 7 дефолтним профілем + Windows Terminal дефолтним застосунком
- **Шпалери** — налаштуй вручну у Wallpaper Engine

### Нотатка про безпеку

Токени і кеш **не** зберігаються (див. `.gitignore`). Плагіни Spotify / Steam потребують перелогіну після відновлення.
