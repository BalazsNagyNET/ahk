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

    RDPServer := "tag-1354.sygic.local"
    Run, mstsc.exe /v:%RDPServer% ; Launch RDP connection to the specified server
}
else {
    MsgBox Disconnected
}
return