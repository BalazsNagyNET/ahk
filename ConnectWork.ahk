; Ctrl+Alt+W: connect FortiClient VPN (SSO), then open workstation in Windows App
; Assumes the FortiClient console is already running (Windows startup).
#SingleInstance Force
#NoEnv
SetTitleMatchMode, 2

; --- config ---
global WorkstationHost := "D-SGC-13241.sygic.local"
global WorkstationName := "D-SGC-13241"
global FortiWinTitle := "FortiClient - Zero Trust Fabric Agent"
global WindowsAppUri := "shell:AppsFolder\MicrosoftCorporationII.Windows365_8wekyb3d8bbwe!Windows365"
global VpnTimeoutSec := 180

^!w::
    ; VPN already up? Then go straight to the workstation.
    if (HostReachable(WorkstationHost)) {
        TrayTip, Connect Work, VPN already up - opening workstation..., 5, 1
        OpenWorkstation()
        return
    }

    ; The console window dies when closed - only the tray/services stay.
    ; If the client itself is not running, bail; otherwise open its window.
    ColdStart := false
    if !WinExist(FortiWinTitle) {
        Process, Exist, FortiClient.exe
        if (!ErrorLevel) {
            TrayTip, Connect Work, FortiClient is not running - start it first, 10, 3
            return
        }
        Run, C:\Program Files\Fortinet\FortiClient\FortiClientConsole.exe
        WinWait, %FortiWinTitle%, , 20
        if ErrorLevel {
            TrayTip, Connect Work, FortiClient window did not open, 10, 3
            return
        }
        ColdStart := true
    }
    WinActivate, %FortiWinTitle%
    WinWaitActive, %FortiWinTitle%, , 5

    ; Wait until the blue Connect button (0x0078BD) is rendered, then click.
    ; On a cold start give the Electron UI extra time to attach handlers.
    CoordMode, Pixel, Window
    CoordMode, Mouse, Window
    ButtonReady := false
    Loop, 20 {
        PixelGetColor, px, 395, 480, RGB
        if (px = 0x0078BD) {
            ButtonReady := true
            break
        }
        Sleep, 500
    }
    if (!ButtonReady) {
        TrayTip, Connect Work, Connect button not found in FortiClient, 10, 3
        return
    }
    Sleep, % (ColdStart ? 2500 : 300)
    Loop, 2 {
        Click, 433, 488
        ; Success = screen changes (connecting view or SSO browser on top)
        Clicked := false
        Loop, 10 {
            Sleep, 500
            PixelGetColor, px, 395, 480, RGB
            if (px != 0x0078BD) {
                Clicked := true
                break
            }
        }
        if (Clicked)
            break
    }

    ; Wait for the tunnel: workstation becomes reachable (SSO may need input)
    TrayTip, Connect Work, Waiting for SSO / tunnel (max %VpnTimeoutSec%s)..., 5, 1
    StartTime := A_TickCount
    Loop {
        if (HostReachable(WorkstationHost))
            break
        if ((A_TickCount - StartTime) / 1000 > VpnTimeoutSec) {
            TrayTip, Connect Work, VPN did not come up - finish SSO manually?, 10, 3
            return
        }
        Sleep, 3000
    }
    TrayTip, Connect Work, VPN connected - opening workstation..., 5, 1
    WinMinimize, %FortiWinTitle%
    OpenWorkstation()
return

OpenWorkstation() {
    global WindowsAppUri, WorkstationName
    Run, explorer.exe %WindowsAppUri%
    RunWait, powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%A_ScriptDir%\connect_workstation.ps1" -DeviceName "%WorkstationName%", , Hide UseErrorLevel
    if (ErrorLevel != 0)
        TrayTip, Connect Work, Could not auto-open %WorkstationName% in Windows App, 10, 3
    else
        TrayTip, Connect Work, %WorkstationName% connecting..., 5, 1
}

HostReachable(host) {
    ; Workstation drops ICMP, so probe the RDP port instead
    psCmd = $t=New-Object Net.Sockets.TcpClient;$r=$t.BeginConnect('%host%',3389,$null,$null);if($r.AsyncWaitHandle.WaitOne(2000) -and $t.Connected){$t.Close();exit 0}else{exit 1}
    RunWait, powershell.exe -NoProfile -Command "%psCmd%", , Hide UseErrorLevel
    return (ErrorLevel = 0)
}
