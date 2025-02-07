@echo off
setlocal

:: Specify the name of the VPN connection you want to connect to
set "VPNConnectionName=Sygic VPN X"

:: Check the status of the VPN connection
rasdial "%VPNConnectionName%" | find "connected"
if %errorlevel% equ 0 (
    echo Already connected to VPN "%VPNConnectionName%." Attempting to disconnect...
    rasdial "%VPNConnectionName%" /DISCONNECT
    if %errorlevel% equ 0 (
        echo Disconnected from VPN "%VPNConnectionName%." 
    ) else (
        echo Failed to disconnect from VPN "%VPNConnectionName%."
    )
) else (
    rasphone -d "%VPNConnectionName%"

    :: Check the rasdial error level to see if the connection was successful
    if errorlevel 1 (
        echo Failed to connect to VPN "%VPNConnectionName%".
    ) else (
        echo Connected to VPN "%VPNConnectionName%" successfully.
    )
)

endlocal