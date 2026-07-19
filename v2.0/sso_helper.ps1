# SSO browser helper for ConnectWork.ahk (Chrome).
# -Mode ClickAccount: waits for the Microsoft account picker and clicks the given account.
# -Mode CloseTab:     closes the SSO/success tab (title matched by -TabPattern).
param(
    [Parameter(Mandatory)][ValidateSet('ClickAccount','CloseTab')][string]$Mode,
    [string]$Email = "nagybal@eurowag.com",
    [string]$TabPattern = '^(Sign in to your account|FortiClient|Fortinet|SAML|Login Succeeded|localhost:\d+/\?tokenid=)',
    [int]$TimeoutSec = 90
)

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win32Sso {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
'@

function Get-ChromeWindows {
    $desktop = [System.Windows.Automation.AutomationElement]::RootElement
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ClassNameProperty, 'Chrome_WidgetWin_1')
    $wins = @()
    foreach ($w in $desktop.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)) {
        try {
            $proc = Get-Process -Id $w.Current.ProcessId -ErrorAction Stop
            if ($proc.Name -eq 'chrome' -and $w.Current.Name) { $wins += $w }
        } catch {}
    }
    return $wins
}

function Click-Element($el, $hwnd) {
    $invoked = $false
    try {
        $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
        $invoked = $true
    } catch {}
    if (-not $invoked) {
        [Win32Sso]::SetForegroundWindow([IntPtr]$hwnd) | Out-Null
        Start-Sleep -Milliseconds 300
        $r = $el.Current.BoundingRectangle
        [Win32Sso]::SetCursorPos([int]($r.X + $r.Width / 2), [int]($r.Y + $r.Height / 2)) | Out-Null
        Start-Sleep -Milliseconds 150
        [Win32Sso]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
        [Win32Sso]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    }
}

if ($Mode -eq 'ClickAccount') {
    # Wait for the picker tab, then click the account entry. The picker may be
    # skipped entirely (silent SSO) - timing out is not an error.
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $win = Get-ChromeWindows | Where-Object { $_.Current.Name -match 'Sign in to your account' } | Select-Object -First 1
        if ($win) {
            $all = $win.FindAll([System.Windows.Automation.TreeScope]::Descendants,
                [System.Windows.Automation.Condition]::TrueCondition)
            $entry = $all | Where-Object {
                $_.Current.Name -match [regex]::Escape($Email) -and
                $_.Current.ControlType -in @([System.Windows.Automation.ControlType]::ListItem,
                                             [System.Windows.Automation.ControlType]::Button)
            } | Select-Object -First 1
            if ($entry) {
                Click-Element $entry $win.Current.NativeWindowHandle
                Write-Output "Clicked account '$Email'"
                exit 0
            }
        }
        Start-Sleep -Seconds 1
    }
    Write-Output "Account picker not seen within ${TimeoutSec}s (silent SSO?)"
    exit 0
}

if ($Mode -eq 'CloseTab') {
    # Find a Chrome tab whose title matches the SSO/success pattern, select it, Ctrl+W.
    foreach ($win in Get-ChromeWindows) {
        $cond = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::TabItem)
        $tabs = $win.FindAll([System.Windows.Automation.TreeScope]::Descendants, $cond)
        $tab = $tabs | Where-Object { $_.Current.Name -match $TabPattern } | Select-Object -First 1
        if ($tab) {
            $title = $tab.Current.Name
            try {
                $tab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select()
            } catch {}
            [Win32Sso]::SetForegroundWindow([IntPtr]$win.Current.NativeWindowHandle) | Out-Null
            Start-Sleep -Milliseconds 400
            (New-Object -ComObject WScript.Shell).SendKeys('^w')
            Write-Output "Closed tab '$title'"
            exit 0
        }
    }
    Write-Output "No SSO tab matching '$TabPattern' found"
    exit 0
}
