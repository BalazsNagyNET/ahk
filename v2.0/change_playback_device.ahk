; Ctrl+Alt+S: cycle the default audio playback device on the LOCAL machine.
; (Not Ctrl+Alt+A - that is KeePass global auto-type.)
; Works even while a Windows App remote session has keyboard focus - the
; hooked hotkey intercepts the keystroke before msrdc gets it, so it never
; reaches the remote machine. (Win+key combos can't be used here: msrdc's
; own low-level hook consumes those first and re-routes them to the session.)
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
SetTitleMatchMode 2

SessionWin := "ahk_class TscShellContainerClass ahk_exe msrdc.exe"
Devices := ["Speakers", "Headset", "Earbuds"]
CurrentDeviceIndex := 0
ToastGui := 0

#UseHook
^!s:: {
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

; msrdc installs its own low-level keyboard hook when the session gains
; focus and eats Win+key combos before we see them (media keys pass through
; it, Win combos do not). Force-reinstall our hook after each activation so
; it sits in front of msrdc's in the hook chain.
Loop {
    WinWaitActive SessionWin
    Sleep 500
    InstallKeybdHook true, true
    Suspend true
    Suspend false
    WinWaitNotActive SessionWin
}
