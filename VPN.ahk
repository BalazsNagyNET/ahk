^!v:: ; This hotkey (Ctrl+Alt+V) triggers the script
    ;identify monitors: mstsc /l
    RDPFile := "tag-1354.rdp"
    ; Call the Python script to update the RDP file
    RunWait, py update_rdp_monitors.py
    Run, %RDPFile% ; Launch RDP connection using the .rdp file
return
