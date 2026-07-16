try:
    import win32api
    import win32con
except ImportError:
    print("The 'pywin32' library is not installed. Please install it using the following command:")
    print("py -m pip install pywin32")
    exit(1)

def list_monitors():
    # Get the display devices
    device_number = 0
    monitors = []
    while True:
        try:
            device = win32api.EnumDisplayDevices(None, device_number)
            if not device:
                break

            # Get the display settings for the device
            try:
                settings = win32api.EnumDisplaySettings(device.DeviceName, win32con.ENUM_CURRENT_SETTINGS)
                monitors.append((device_number, settings.PelsWidth))
            except Exception as e:
                pass

            device_number += 1
        except Exception as e:
            break
    return monitors

def update_rdp_file(rdp_file_path, monitors):
    # Sort monitors by width in descending order
    monitors.sort(key=lambda x: x[1], reverse=True)
    # Get the two monitors with the largest width
    selected_monitors = [str(monitors[0][0]), str(monitors[1][0])]

    # Read the RDP file
    with open(rdp_file_path, 'r') as file:
        lines = file.readlines()

    # Update the selectedmonitors line
    for i, line in enumerate(lines):
        if line.startswith("selectedmonitors:s:"):
            lines[i] = f"selectedmonitors:s:{','.join(selected_monitors)}\n"
            break

    # Write the updated RDP file
    with open(rdp_file_path, 'w') as file:
        file.writelines(lines)

if __name__ == "__main__":
    rdp_file_path = "tag-1354.rdp"
    monitors = list_monitors()
    update_rdp_file(rdp_file_path, monitors)
