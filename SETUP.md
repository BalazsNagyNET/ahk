# ConnectWork — one-hotkey VPN + workstation connect (Ctrl+Alt+W)

Connects FortiClient VPN (SSO), then opens your workstation in Windows App. If the VPN is already up, it skips straight to the workstation.

## Files

- `ConnectWork.ahk` — the hotkey script
- `connect_workstation.ps1` — clicks your device tile in Windows App (must sit in the same folder)

## Setup

1. Install [AutoHotkey v1.1](https://www.autohotkey.com) (not v2 — the script is v1 syntax).
2. Edit the config at the top of `ConnectWork.ahk`:
   - `WorkstationHost` — your PC's FQDN, e.g. `D-SGC-XXXXX.sygic.local`
   - `WorkstationName` — the device name exactly as shown on your tile in Windows App
3. In Windows App, add your PC under **Devices** if it isn't there (Devices → Add → Remote PC). Optional: tile **⋯ → Settings → Display** to pick which monitors the session uses — the script reuses whatever you save there.
4. FortiClient must be installed with the SSO VPN profile and running (it normally starts with Windows).
5. Double-click `ConnectWork.ahk`. To start it with Windows, put a shortcut to it in `shell:startup`.

## Known quirks

- FortiClient has no automation API, so the script finds the blue Connect button by pixel color and clicks fixed coordinates (tuned at 100% display scaling). Different scaling or FortiClient version can make the click miss — adjust the coordinates in the script.
- SSO still needs your input in the browser; the script waits up to 3 minutes for the tunnel.
- "VPN up" is detected by probing `WorkstationHost` on TCP 3389, so the FQDN must be correct.
