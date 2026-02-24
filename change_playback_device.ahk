#Persistent			; This keeps the script running permanently.
#SingleInstance		; Only allows one instance of the script to run.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Win+A to change Audio Playback Device
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#a::
	; Define device list in order of preference
	global currentDeviceIndex
	devices := ["Speakers", "Headset", "Earbuds"]
	
	; Initialize index if not set
	if (currentDeviceIndex = "")
		currentDeviceIndex := 0
	
	; Move to next device (cycle around)
	currentDeviceIndex := Mod(currentDeviceIndex, devices.Length()) + 1
	nextDevice := devices[currentDeviceIndex]
	
	; Set the new default device
	Run nircmd setdefaultsounddevice "%nextDevice%"
	soundToggleBox(nextDevice)
Return

; Display sound toggle GUI
soundToggleBox(Device)
{
	IfWinExist, soundToggleWin
	{
		Gui, destroy
	}
	
	Gui, +ToolWindow -Caption +0x400000 +alwaysontop
	Gui, Add, text, x35 y8, Default sound: %Device%
	SysGet, screenx, 0
	SysGet, screeny, 1
	xpos:=screenx-275
	ypos:=screeny-100
	Gui, Show, NoActivate x%xpos% y%ypos% h30 w200, soundToggleWin
	
	SetTimer,soundToggleClose, 2000
}
soundToggleClose:
    SetTimer,soundToggleClose, off
    Gui, destroy
Return