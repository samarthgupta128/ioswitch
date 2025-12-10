# IO Switch - Firefox Extension

A **cross-platform** Firefox extension that automatically opens specified websites in your default external browser (e.g., Chrome, Edge, Chromium) instead of loading them in Firefox.

This is useful for websites that don't work properly in Firefox but work fine in other browsers.

## Features

- 🔀 Automatically redirects specified domains to your default browser
- ⚙️ Easy-to-use popup interface to manage redirect domains
- 🌐 Supports subdomains (e.g., adding `x.ai` also redirects `www.x.ai`, `chat.x.ai`, etc.)
- 💾 Settings are saved and persist across browser restarts
- 🖥️ **Cross-platform**: Works on Windows and Linux (Ubuntu)

## Installation

### Step 1: Install the Extension

#### Option A: Temporary Installation (for development/testing)

1. Open Firefox and go to `about:debugging`
2. Click "This Firefox" in the left sidebar
3. Click "Load Temporary Add-on..."
4. Navigate to the extension folder and select `manifest.json`

#### Option B: Permanent Installation

1. Package the extension as a `.xpi` file
2. Go to `about:addons` in Firefox
3. Click the gear icon and select "Install Add-on From File..."
4. Select the `.xpi` file

### Step 2: Install the Native Messaging Host

The native messaging host is required to open URLs in an external browser.

#### Windows

1. Open the `native-host\windows` folder
2. **Right-click** on `install_host.bat` and select **"Run as administrator"**
3. Follow the on-screen instructions
4. Restart Firefox

#### Linux (Ubuntu/Debian)

1. Open a terminal and navigate to the extension folder:
   ```bash
   cd /path/to/ioswitch/native-host/linux
   ```

2. Make the scripts executable:
   ```bash
   chmod +x install_host.sh ioswitch_host.sh
   ```

3. Run the installer with sudo:
   ```bash
   sudo ./install_host.sh
   ```

4. Restart Firefox

**Note for Ubuntu 22.04+**: If you're using Firefox as a Snap package, the installer will automatically configure the native host for Snap. The same applies for Flatpak installations.

## Usage

1. Click the IO Switch icon (🔀) in the Firefox toolbar
2. Add domains you want to redirect (e.g., `x.ai`, `grok.com`)
3. When you visit any of these domains, they will automatically open in your default browser

### Default Domains

The extension comes pre-configured with:
- `x.ai`
- `grok.com`

You can add or remove domains at any time through the popup interface.

## How It Works

1. The extension monitors all web requests in Firefox
2. When you navigate to a configured domain, the request is blocked
3. The URL is sent to the native messaging host
4. The native host opens the URL in your system's default browser
5. The original Firefox tab is closed or shows a redirect page

## Troubleshooting

### Windows

#### "Native messaging host is not configured" warning

This means the native messaging host isn't properly installed. Try:

1. Re-run `install_host.bat` as Administrator
2. Make sure the registry key was created:
   - Open `regedit`
   - Navigate to `HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\NativeMessagingHosts\ioswitch`
   - The value should point to `C:\ioswitch\ioswitch.json`
3. Restart Firefox completely

#### PowerShell Execution Policy

If the native host doesn't work, you may need to allow PowerShell scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux

#### "Native messaging host is not configured" warning

1. Re-run the installer: `sudo ./install_host.sh`
2. Check that the manifest symlink exists:
   ```bash
   ls -la /usr/lib/mozilla/native-messaging-hosts/ioswitch.json
   ```
3. For Firefox Snap (Ubuntu 22.04+), check:
   ```bash
   ls -la ~/snap/firefox/common/.mozilla/native-messaging-hosts/ioswitch.json
   ```
4. Restart Firefox completely

#### URLs not opening in external browser

1. Make sure `xdg-open` is installed: `which xdg-open`
2. Check your default browser: `xdg-settings get default-web-browser`
3. Set a default browser if needed:
   ```bash
   xdg-settings set default-web-browser google-chrome.desktop
   # or
   xdg-settings set default-web-browser chromium.desktop
   ```

### General

### General

1. Check that your default browser is set correctly in system settings
2. Verify the domain is in your redirect list
3. Check the Firefox Browser Console (Ctrl+Shift+J) for error messages

## Uninstallation

### Windows
1. Remove the extension from Firefox (`about:addons`)
2. Run `native-host\windows\uninstall_host.bat` as Administrator

### Linux
1. Remove the extension from Firefox (`about:addons`)
2. Run: `sudo ./native-host/linux/uninstall_host.sh`

## File Structure

```
ioswitch/
├── manifest.json          # Extension manifest
├── background.js          # Background script (intercepts requests)
├── popup.html             # Popup UI
├── popup.js               # Popup logic
├── redirect.html          # Fallback page (when native host unavailable)
├── icon.svg               # Extension icon
├── README.md              # This file
└── native-host/
    ├── windows/           # Windows native host files
    │   ├── ioswitch.json      # Native messaging manifest
    │   ├── ioswitch_host.bat  # Batch wrapper
    │   ├── ioswitch_host.ps1  # PowerShell script (opens URLs)
    │   ├── install_host.bat   # Installer (run as admin)
    │   └── uninstall_host.bat # Uninstaller (run as admin)
    └── linux/             # Linux native host files
        ├── ioswitch.json      # Native messaging manifest
        ├── ioswitch_host.sh   # Shell script (opens URLs)
        ├── install_host.sh    # Installer (run with sudo)
        └── uninstall_host.sh  # Uninstaller (run with sudo)
```

## Privacy

This extension:
- Does NOT collect any data
- Does NOT send any data to external servers
- Only stores your list of redirect domains locally in Firefox

## License

MIT License - Feel free to modify and distribute.
