; Keeps media/volume keys working on the LOCAL machine while a Windows App
; remote session has keyboard focus. The session window is hosted by msrdc.exe
; (class TscShellContainerClass, title = device name).
#Requires AutoHotkey v2.0
#SingleInstance Force
KeyHistory 0
A_IconTip := "RDP Hotkey Helper (Windows App)"

SessionWin := "ahk_class TscShellContainerClass ahk_exe msrdc.exe"

#UseHook
Volume_Mute::PassToLocalMachine()
Volume_Down::PassToLocalMachine()
Volume_Up::PassToLocalMachine()
Media_Next::PassToLocalMachine()
Media_Prev::PassToLocalMachine()
Media_Stop::PassToLocalMachine()
Media_Play_Pause::PassToLocalMachine()

PassToLocalMachine() {
    static WM_APPCOMMAND := 0x0319
    static AppCommands := Map(
        "Volume_Mute", 8,
        "Volume_Down", 9,
        "Volume_Up", 10,
        "Media_Next", 11,
        "Media_Prev", 12,
        "Media_Stop", 13,
        "Media_Play_Pause", 14)
    if !WinActive(SessionWin) {
        Send "{" A_ThisHotkey "}"
        return
    }
    PostMessage WM_APPCOMMAND, 0, AppCommands[A_ThisHotkey] << 16, , "ahk_class Shell_TrayWnd"
}

; Rebind the hotkeys whenever a session gains focus, otherwise they stop
; working in fullscreen mode. Also restore num lock, which the remote
; desktop client disables upon first connection.
Loop {
    WinWaitActive SessionWin
    Suspend true
    Suspend false
    Sleep 250
    SetNumLockState true
    WinWaitNotActive SessionWin
}
