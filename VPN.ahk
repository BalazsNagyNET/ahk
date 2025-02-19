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
    ;identify monitors: mstsc /l
    RDPFile := "tag-1354.rdp"
    ; Call the Python script to update the RDP file
    RunWait, python update_rdp_monitors.py
    Run, %RDPFile% ; Launch RDP connection using the .rdp file
}
else {
    MsgBox Disconnected
}
return
