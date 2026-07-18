# v2.0 — AutoHotkey v2 scripts for Windows App

Scripts written for AutoHotkey **v2** (`#Requires AutoHotkey v2.0`), targeting remote
sessions opened through **Windows App** (session window is hosted by `msrdc.exe`,
class `TscShellContainerClass`, window title = device name).

## Hotkeys

| Hotkey | Script | What it does |
|---|---|---|
| Ctrl+Alt+W | `ConnectWork.ahk` | Connect FortiClient VPN (SSO, auto-picks account and cleans up the browser tab), then open the workstation in Windows App |
| Ctrl+Alt+S | `change_playback_device.ahk` | Cycle local default playback device (Speakers → Headset → Earbuds), works inside the remote session |
| Shift+CapsLock | `minimize_activate_shift_caps.ahk` | Minimize active window; press again to restore and activate it |
| Volume/media keys | `RDPHotkeyHelper.ahk` | Keep volume/media keys acting on the local machine while the remote session has focus; also restores NumLock on connect |

Ctrl+Alt+A is intentionally not used — reserved by KeePass global auto-type.

## Files

- `ConnectWork.ahk` — Ctrl+Alt+W flow: checks VPN by probing the workstation on TCP 3389,
  clicks the FortiClient Connect button by pixel color (no automation API), waits for the
  SSO tunnel, then opens Windows App and clicks the device tile. Config (workstation
  FQDN/name) at the top of the script.
- `connect_workstation.ps1` — helper used by ConnectWork: finds the device tile in
  Windows App via UI Automation and invokes it.
- `sso_helper.ps1` — helper used by ConnectWork: auto-clicks the right account in the
  Chrome SSO account picker and closes the leftover SSO tab once the VPN is up.
  Account email and tab-title pattern are parameters.
- `RDPHotkeyHelper.ahk` — media/volume key pass-to-local helper.
- `change_playback_device.ahk` — audio device cycler; uses `nircmd.exe` (bundled).
  Win+key combos cannot be used for this: msrdc's low-level keyboard hook consumes
  them before AutoHotkey and re-routes them to the session.
- `minimize_activate_shift_caps.ahk` — minimize/restore toggle.
- `nircmd.exe` — NirSoft utility used to switch the default sound device.

## Setup

1. Install [AutoHotkey v2](https://www.autohotkey.com).
2. Adjust config at the top of `ConnectWork.ahk` and the device list in
   `change_playback_device.ahk`.
3. Windows App: add your PC under Devices; pick monitors per device under
   tile ⋯ → Settings → Display (the session reuses whatever you save there).
4. Autostart: put shortcuts to the `.ahk` files in `shell:startup`.

See `../v1.1/SETUP.md` for the more detailed ConnectWork walkthrough (v1 paths).
