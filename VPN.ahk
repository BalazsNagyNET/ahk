; Replace the path with the actual path to your batch script
BatchScriptPath := ".\ConnectToVPN.bat"
VPNName := "Sygic VPN"
ConnectWindowTitle := "Connect " . VPNName
ConncetingWindowTitle := "Connecting to " . VPNName
^!v:: ; This hotkey (Ctrl+Alt+V) triggers the script
Run, %BatchScriptPath%, , Hide

Sleep, 2000 ; Wait for 2000 milliseconds (2 seconds)

; Get the title of the active window
WinGetTitle, ActiveWindowTitle, A

if (ActiveWindowTitle = ConnectWindowTitle) {
    Send, {Enter} ; Send the Enter key
    Sleep, 1000
    ; Wait until connection is established
    WinWaitClose, %ConncetingWindowTitle%
    
    ; Identify monitors: mstsc /l
    RunWait, %ComSpec% /c mstsc /l > monitor_list.txt,, Hide
    FileRead, MonitorList, monitor_list.txt
    
    ; Parse the output to find the two monitors with the highest resolutions
    MonitorArray := []
    Loop, Parse, MonitorList, `n, `r
    {
        if (RegExMatch(A_LoopField, "Monitor (\d+): (\d+) x (\d+)", Match))
        {
            MonitorIndex := Match1
            MonitorWidth := Match2
            MonitorHeight := Match3
            MonitorResolution := MonitorWidth * MonitorHeight
            MonitorArray.Push({Index: MonitorIndex, Resolution: MonitorResolution})
        }
    }
    
    ; Sort the monitors by resolution in descending order
    MonitorArray.Sort("a.Resolution > b.Resolution")
    
    ; Get the indices of the two monitors with the highest resolutions
    Monitor1 := MonitorArray[1].Index
    Monitor2 := MonitorArray[2].Index
    
    ; Update the selectedmonitors line in the RDP file
    RDPFile := "tag-1354.rdp"
    FileRead, RDPContent, %RDPFile%
    RDPContent := RegExReplace(RDPContent, "selectedmonitors:s:\d+,\d+", "selectedmonitors:s:" . Monitor1 . "," . Monitor2)
    FileDelete, %RDPFile%
    FileAppend, %RDPContent%, %RDPFile%
    
    Run, %RDPFile% ; Launch RDP connection using the .rdp file
}
else {
    MsgBox Disconnected
}
return
