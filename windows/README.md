# StrainAway (Windows) ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A minimalist Windows system tray app that reminds you to follow the
20-20-20 rule for reducing digital eye strain: every 20 minutes, look
at something 20 metres away for 20 seconds.

This is the Windows counterpart to the native macOS version found in
the mac/ folder of this repository, built in Python rather than Swift.
For setup and build instructions for the Mac version of this app see the [mac README.md](../mac/README.md) file.

# FEATURES
- Lives quietly in the system tray, no taskbar window
- Sends a native Windows notification every 20 minutes
- Start/stop reminders from the tray icon's right-click menu
- Optional "launch at login" toggle, so it starts automatically on boot
- Custom tray icon and app icon

# REQUIREMENTS
- Windows 10 or later
- Python 3.10+, if building from source

# BUILDING FROM SOURCE
1. Clone this repository.
2. Open the windows/ folder in VS Code (or your editor of choice).
3. Create a virtual environment:
   python -m venv venv
4. Activate it:
   venv\Scripts\activate
5. Install dependencies:
   pip install -r requirements.txt
6. Run it:
   python main.py

# CREATING A STANDALONE .EXE
1. Convert your app icon PNG to .ico first, if not already done:
   python convert_icon.py
2. Build the executable:
   pyinstaller --windowed --onefile --icon="assets/app_icon.ico" --add-data "assets;assets" --name StrainAway main.py
3. Find the finished .exe inside the dist/ folder.

Note: PyInstaller does not cross-compile. This build must be run on an
actual Windows machine (or Windows VM) to produce a working .exe — it
cannot be built from macOS or Linux.

# FIRST LAUNCH
- Windows will ask for notification permission, or may silently allow
  it depending on your notification settings. If reminders don't
  appear, check Settings > System > Notifications and confirm
  StrainAway is allowed.
- Since this app is not signed with a paid code-signing certificate,
  Windows Defender SmartScreen will likely show "Windows protected
  your PC" the first time it's run. Click "More info", then "Run
  anyway" to proceed. This is expected for an unsigned personal
  project, not a sign of a broken build.
- If you use Windows' Focus Assist, add an exception for this app, or
  reminders will be silently suppressed while it's active.

# LAUNCH AT LOGIN
Toggle this from the tray icon's right-click menu. This writes an
entry to the Windows registry (Software\Microsoft\Windows\CurrentVersion\Run)
pointing at the running executable.

# KNOWN LIMITATIONS
- The tray icon does not automatically adapt to light/dark taskbar
  mode changes while running; it's set once at launch based on the
  current system theme, using two separate icon files rather than a
  single adaptive image.
- The small icon shown on Windows notifications is subject to the
  same kind of OS-level caching behaviour as on macOS, and may not
  always reflect the very latest icon change without a full rebuild
  or restart.

# PRIVACY
StrainAway does not collect, store, or transmit any data. It makes no
network requests. The only system permission it requests is local
notification access, used solely to display break reminders. Nothing
about your usage, screen content, or activity is monitored, logged, or
sent anywhere.

The only persistent change it makes to your system is a single
registry entry (Windows) or LaunchAgent file (macOS) if you enable
"launch at login" — both are standard, removable via the app's own
toggle.

This is open source — you're welcome to verify all of this by reading
the source code directly.

# LICENCE
This project is licensed under the MIT License — see the [LICENSE](../LICENSE.txt) file
in the root of this repository.

# FURTHER READING ON THE 20-20-20 RULE
[Deconstructing the 20-20-20 rule for digital eye strain](https://www.optometrytimes.com/view/deconstructing-20-20-20-rule-digital-eye-strain) — Optometry Times

# AUTHOR
ClinicalScript
