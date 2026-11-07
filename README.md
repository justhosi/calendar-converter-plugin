# Omarchy Calendar Converter

A minimal **Omarchy shell** bar plugin that converts dates between **Solar Hijri (Jalali/Persian)** and **Gregorian** calendars — in both directions.

## Features

- **Any date conversion** (not just “today”): enter Year / Month / Day and convert.
- **Both directions:** `Jalali → Gregorian` and `Gregorian → Jalali` (swap with the button or press `S`).
- **Minimal, clean UI:** a small bar button (`⇄`) opens a native Omarchy keyboard/popup panel.
- **Local only:** all conversion runs locally in the plugin (no network access).
- **Input-friendly:** accepts Persian/Arabic-Indic digits; validates dates before converting.
- **Copy result:** copy the converted date to the clipboard (`wl-copy`).

## Plugin details

| Field | Value |
|---|---|
| Plugin ID | `hosi.jalali-gregorian-converter` |
| Kind | `bar-widget` |
| Default section | `centerEnd` |
| Author | Hosi |

## Requirements

- [Omarchy](https://omarchy.org/) with the Omarchy shell (Quickshell-based bar/panels).
- `wl-copy` available on your system for the **Copy** action (standard on Omarchy/Wayland setups).

## Installation

### Option 1: Clone into Omarchy user plugins (recommended)

Run this command in a terminal:

```bash
git clone https://github.com/justhosi/calendar-converter-plugin ~/.config/omarchy/plugins/hosi.jalali-gregorian-converter
```

Then rescan plugins:

```bash
omarchy-shell shell rescanPlugins
```

Add the widget to your bar (example: `centerEnd`):

```bash
omarchy bar put hoshi.jalali-gregorian-converter --section centerEnd
```

If `omarchy bar put`/`omarchy plugin enable` does not add it in your Omarchy version, you can add it manually to `~/.config/omarchy/shell.json` under `bar.layout.centerEnd`:

```json
{
  "id": "hosi.jalali-gregorian-converter"
}
```

`~/.config/omarchy/shell.json` hot-reloads on save.

### Option 2: Install with `omarchy plugin add`

```bash
omarchy plugin add https://github.com/justhosi/calendar-converter-plugin.git --enable
```

After installing, make sure the widget is placed in your bar layout (see Option 1). You may need to rescan:

```bash
omarchy-shell shell rescanPlugins
```

### Option 3: Keep source in a dev folder and symlink

```bash
git clone https://github.com/justhosi/calendar-converter-plugin ~/dev/omarchy-calendar-converter
ln -s ~/dev/omarchy-calendar-converter ~/.config/omarchy/plugins/hosi.jalali-gregorian-converter
omarchy-shell shell rescanPlugins
```

## Usage

1. Click the **`⇄`** button in the bar to open the converter panel.
2. Choose direction:
   - **Jalali → Gregorian** converts a Solar Hijri date to Gregorian.
   - **Gregorian → Jalali** converts a Gregorian date to Solar Hijri.
   - Swap with the direction button or press **`S`**.
3. Enter **Year**, **Month**, and **Day**.
4. Press **Enter** or click **Convert**.
5. Click **Copy** to copy the result.

**Panel shortcuts:** `Enter` convert · `S` swap direction · `Tab` switches panels (Omarchy panel behavior) · close via normal panel close/Escape behavior.

## Date format notes

- Result format: `YYYY/MM/DD`.
- Jalali validation includes month lengths and leap-year handling for Esfand (month 12).
- Gregorian validation checks real calendar dates.

## Project structure

```text
.
├── manifest.json      # Omarchy plugin manifest (schemaVersion 1)
├── BarWidget.qml      # Bar button + panel loader/IPC
├── Panel.qml          # Minimal converter popup UI
├── Model.js           # Jalali/Gregorian conversion and validation logic
└── i18n/
    └── en.json        # Basic UI strings
```

## Updating

If installed by git clone:

```bash
cd ~/.config/omarchy/plugins/hosi.jalali-gregorian-converter
git pull
omarchy-shell shell rescanPlugins
```

## Uninstall

Remove the widget entry from `~/.config/omarchy/shell.json` (if present), then remove the plugin:

```bash
rm -rf ~/.config/omarchy/plugins/hosi.jalali-gregorian-converter
omarchy-shell shell rescanPlugins
```

Or, if managed by Omarchy plugin commands:

```bash
omarchy plugin remove hoshi.jalali-gregorian-converter --yes
```

## Credits

- Conversion logic is based on the common `mjnaderi/Jalali.py`-style algorithm (also referenced in existing Omarchy Persian calendar plugin implementations).
- Built for the Omarchy shell plugin system.
