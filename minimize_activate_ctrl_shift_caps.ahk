#SingleInstance force
#InstallKeybdHook
#UseHook

SetTitleMatchMode, 2
min := true

;Toggle Action (Min/Max) Win+Shift+Caps
;In case your last window is minned and you want to min a new window
#+CapsLock::
min := !min
return

;Toggle window state Ctrl+Shift+Caps 
^+CapsLock::
if (min == true)
{
    WinGetTitle, WinLastTitle, A
    WinMinimize, A 
} else {
    WinActivate, %WinLastTitle%
}

min := !min

return