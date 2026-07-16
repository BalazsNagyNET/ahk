; Win+A: cycle the default audio playback device on the LOCAL machine.
; Works even while a Windows App remote session has keyboard focus - the
; hotkey is hooked and rebound on session focus, same trick as RDPHotkeyHelper,
; so the keystroke never reaches the remote machine.
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
SetTitleMatchMode 2

SessionWin := "ahk_class TscShellContainerClass ahk_exe msrdc.exe"
Devices := ["Speakers", "Headset", "Earbuds"]
CurrentDeviceIndex := 0
ToastGui := 0

#UseHook
#a:: {
    global CurrentDeviceIndex
    CurrentDeviceIndex := Mod(CurrentDeviceIndex, Devices.Length) + 1
    nextDevice := Devices[CurrentDeviceIndex]
    Run A_ScriptDir '\nircmd.exe setdefaultsounddevice "' nextDevice '"', , "Hide"
    ShowToast("Default sound: " nextDevice)
}

ShowToast(text) {
    global ToastGui
    HideToast()
    ToastGui := Gui("+ToolWindow -Caption +AlwaysOnTop")
    ToastGui.Add("Text", "x35 y8", text)
    ToastGui.Show("NoActivate x" (A_ScreenWidth - 275) " y" (A_ScreenHeight - 100) " w200 h30")
    SetTimer HideToast, -2000
}

HideToast() {
    global ToastGui
    if (ToastGui) {
        ToastGui.Destroy()
        ToastGui := 0
    }
}

; Rebind the hotkey whenever a session gains focus, otherwise it stops
; working in fullscreen mode and the keystroke goes to the remote machine.
Loop {
    WinWaitActive SessionWin
    Suspend true
    Suspend false
    WinWaitNotActive SessionWin
}
