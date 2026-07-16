; Ctrl+Alt+W: connect FortiClient VPN (SSO), then open workstation in Windows App
; Assumes the FortiClient client is already running (Windows startup).
#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

; --- config ---
WorkstationHost := "D-SGC-13241.sygic.local"
WorkstationName := "D-SGC-13241"
FortiWinTitle := "FortiClient - Zero Trust Fabric Agent"
WindowsAppUri := "shell:AppsFolder\MicrosoftCorporationII.Windows365_8wekyb3d8bbwe!Windows365"
VpnTimeoutSec := 180

^!w:: {
    ; VPN already up? Then go straight to the workstation.
    if HostReachable(WorkstationHost) {
        TrayTip "VPN already up - opening workstation...", "Connect Work", 1
        OpenWorkstation()
        return
    }

    ; The console window dies when closed - only the tray/services stay.
    ; If the client itself is not running, bail; otherwise open its window.
    ColdStart := false
    if !WinExist(FortiWinTitle) {
        if !ProcessExist("FortiTray.exe") {
            TrayTip "FortiClient is not running - start it first", "Connect Work", 3
            return
        }
        Run 'C:\Program Files\Fortinet\FortiClient\FortiClientConsole.exe'
        if !WinWait(FortiWinTitle, , 20) {
            TrayTip "FortiClient window did not open", "Connect Work", 3
            return
        }
        ColdStart := true
    }
    WinActivate FortiWinTitle
    WinWaitActive FortiWinTitle, , 5

    ; Wait until the blue Connect button (0x0078BD) is rendered, then click.
    ; On a cold start give the Electron UI extra time to attach handlers.
    CoordMode "Pixel", "Window"
    CoordMode "Mouse", "Window"
    ButtonReady := false
    Loop 20 {
        if (PixelGetColor(395, 480) = 0x0078BD) {
            ButtonReady := true
            break
        }
        Sleep 500
    }
    if !ButtonReady {
        TrayTip "Connect button not found in FortiClient", "Connect Work", 3
        return
    }
    Sleep ColdStart ? 1000 : 300
    Loop 2 {
        Click 433, 488
        ; Success = screen changes (connecting view or SSO browser on top)
        Clicked := false
        Loop 10 {
            Sleep 500
            if (PixelGetColor(395, 480) != 0x0078BD) {
                Clicked := true
                break
            }
        }
        if Clicked
            break
    }

    ; Wait for the tunnel: workstation becomes reachable (SSO may need input)
    TrayTip "Waiting for SSO / tunnel (max " VpnTimeoutSec "s)...", "Connect Work", 1
    StartTime := A_TickCount
    Loop {
        if HostReachable(WorkstationHost)
            break
        if ((A_TickCount - StartTime) / 1000 > VpnTimeoutSec) {
            TrayTip "VPN did not come up - finish SSO manually?", "Connect Work", 3
            return
        }
        Sleep 3000
    }
    TrayTip "VPN connected - opening workstation...", "Connect Work", 1
    WinMinimize FortiWinTitle
    OpenWorkstation()
}

OpenWorkstation() {
    Run "explorer.exe " WindowsAppUri
    exitCode := RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'
        A_ScriptDir '\connect_workstation.ps1" -DeviceName "' WorkstationName '"', , "Hide")
    if (exitCode != 0)
        TrayTip "Could not auto-open " WorkstationName " in Windows App", "Connect Work", 3
    else
        TrayTip WorkstationName " connecting...", "Connect Work", 1
}

HostReachable(host) {
    ; Workstation drops ICMP, so probe the RDP port instead
    psCmd := "$t=New-Object Net.Sockets.TcpClient;$r=$t.BeginConnect('" host "',3389,$null,$null);"
        . "if($r.AsyncWaitHandle.WaitOne(2000) -and $t.Connected){$t.Close();exit 0}else{exit 1}"
    return RunWait('powershell.exe -NoProfile -Command "' psCmd '"', , "Hide") = 0
}
