; Shift+CapsLock: minimize the active window; press again to restore it
; to its previous position/state and activate it.
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
#UseHook

Prev := {id: 0, minmax: 0, x: 0, y: 0, w: 0, h: 0}

+CapsLock:: {
    global Prev
    if (Prev.id) {
        if WinExist("ahk_id " Prev.id) {
            WinRestore
            if (Prev.minmax = 1)
                WinMaximize
            else
                WinMove Prev.x, Prev.y, Prev.w, Prev.h
            WinActivate
        }
        Prev.id := 0
    } else if (id := WinExist("A")) {
        WinGetPos &x, &y, &w, &h
        Prev := {id: id, minmax: WinGetMinMax(), x: x, y: y, w: w, h: h}
        WinMinimize
    }
}
