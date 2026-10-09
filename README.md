# zen-scrollbar

Custom scrollbar colors and width for web pages in [Zen Browser](https://zen-browser.app/). One command, no mod.

## Install

**Windows** (PowerShell, from the repo folder):

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Color "#a78bdb" -Track "#80808055" -Width thin
```

**Linux / macOS**:

```bash
./install.sh
./install.sh "#a78bdb" "#80808055" thin
```

Restart Zen completely. Run again with other values to change them.

| Option | Default | Description |
|---|---|---|
| Color | `#7e62b8` | Thumb (the draggable bar) |
| Track | `#80808033` | Track (the rail behind it); 8-digit hex = alpha |
| Width | `auto` | `auto`, `thin` or `none` (hidden, still scrollable) |

If your profile is not detected: `-ProfilePath <dir>` (Windows) or `PROFILE=<dir>` (Linux/macOS). Find it in `about:support` → Profile Folder.

## Manual install

1. `about:config` → set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`.
2. Copy `userContent.css` to `<profile>/chrome/`.
3. Restart Zen.

## Notes

- Overwrites `chrome/userContent.css` (previous file saved as `.bak`).
- Web pages only; Zen's own UI scrollbars are not affected.
- Delete `userContent.css` to uninstall.

## License

MIT