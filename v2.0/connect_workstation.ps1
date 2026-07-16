# Finds the device tile in Windows App and clicks it to start the remote connection.
# Usage: powershell -ExecutionPolicy Bypass -File connect_workstation.ps1 [-DeviceName "D-SGC-13241"] [-FindOnly]
param(
    [string]$DeviceName = "D-SGC-13241",
    [switch]$FindOnly
)

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
'@

# Wait for the Windows App main window
$deadline = (Get-Date).AddSeconds(60)
$proc = $null
while ((Get-Date) -lt $deadline) {
    $proc = Get-Process Windows365 -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($proc) { break }
    Start-Sleep -Seconds 1
}
if (-not $proc) { Write-Error "Windows App window not found"; exit 1 }

[Win32]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
Start-Sleep -Seconds 1

$root = [System.Windows.Automation.AutomationElement]::FromHandle($proc.MainWindowHandle)
$nameCond = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::NameProperty, $DeviceName)

# Poll for the device tile (the embedded web UI needs time to render).
# Several elements carry the device name; the full card is the largest one
# that supports InvokePattern ("Select the full card to open it").
$deadline = (Get-Date).AddSeconds(45)
$tile = $null
while ((Get-Date) -lt $deadline) {
    $candidates = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, $nameCond)
    $tile = $candidates | Where-Object {
        $_.GetSupportedPatterns().ProgrammaticName -contains 'InvokePatternIdentifiers.Pattern'
    } | Sort-Object { $_.Current.BoundingRectangle.Width * $_.Current.BoundingRectangle.Height } -Descending |
        Select-Object -First 1
    if ($tile) { break }
    Start-Sleep -Seconds 1
}
if (-not $tile) { Write-Error "Device tile '$DeviceName' not found"; exit 2 }

$rect = $tile.Current.BoundingRectangle
Write-Output "Found '$DeviceName' at $([int]$rect.X),$([int]$rect.Y) $([int]$rect.Width)x$([int]$rect.Height)"
if ($FindOnly) { exit 0 }

$invoked = $false
try {
    $pattern = $tile.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $pattern.Invoke()
    $invoked = $true
} catch {}

if (-not $invoked) {
    # Fallback: physical click on the tile center
    $cx = [int]($rect.X + $rect.Width / 2)
    $cy = [int]($rect.Y + $rect.Height / 2)
    [Win32]::SetCursorPos($cx, $cy) | Out-Null
    Start-Sleep -Milliseconds 200
    [Win32]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)  # left down
    [Win32]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)  # left up
}

Write-Output "Connection to '$DeviceName' started"
exit 0
