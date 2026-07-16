#SingleInstance force
#InstallKeybdHook
#UseHook
SetTitleMatchMode, 2

global WinID := "", WinMinMax := 0, WinX := "", WinY := "", WinW := "", WinH := ""

+CapsLock::

if (WinID) {
    if WinExist("ahk_id " WinID) {
        WinRestore, ahk_id %WinID%
        if (WinMinMax = 1)
            WinMaximize, ahk_id %WinID%
        else
            WinMove, ahk_id %WinID%,, WinX, WinY, WinW, WinH
        WinActivate, ahk_id %WinID%
    }
    WinID := ""
} else {
    WinGet, WinID, ID, A
    if (WinID) {
        WinGetPos, WinX, WinY, WinW, WinH, ahk_id %WinID%
        WinGet, WinMinMax, MinMax, ahk_id %WinID%
        WinMinimize, ahk_id %WinID%
    }
}
return