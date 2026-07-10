StrainAway
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
==========

A minimalist macOS menu bar app that reminds you to follow the 20-20-20 rule
for reducing digital eye strain: every 20 minutes, look at something 20 metres
away for 20 seconds.

**Disclaimer: This application is a general wellness tool designed to encourage ergonomic screen breaks. It does not provide medical advice, diagnosis, or treatment. The 20-20-20 guidance is a general habit recommendation and should not replace professional ophthalmic or medical consultation.**

FEATURES
--------
- Lives quietly in the menu bar, no Dock icon
- Sends a native macOS notification every 20 minutes
- Start/stop reminders from the menu bar dropdown
- Optional "launch at login" toggle, so it starts automatically on boot
- Custom app icon and menu bar glyph, with light and dark mode variants

REQUIREMENTS
------------
- macOS Tahoe (26) or later
- Xcode 26 or later, if building from source

BUILDING FROM SOURCE
---------------------
1. Clone this repository.
2. Open the .xcodeproj file in Xcode.
3. Select the app target and press Cmd+R to build and run.
4. To create a standalone copy that runs without Xcode open:
   Product menu -> Archive -> Distribute App -> Copy App.
   Drag the exported .app into /Applications.

FIRST LAUNCH
------------
- macOS will ask for notification permission the first time the app runs.
  Click Allow, or reminders will not appear. It is recommended to set these notifications
  from temporary to persistent, System Settings > Notifications > StrainAway > toggle Altert Style to Persistent
- Since this app is not notarised through the Apple Developer Program,
  Gatekeeper may block it as being from an unidentified developer if
  downloaded rather than built locally. Right-click the app and choose
  Open, then confirm, to run it anyway.
- If you use a Focus or Do Not Disturb mode, add an exception for this
  app, or reminders will be silently suppressed while it's active.

LAUNCH AT LOGIN
----------------
Toggle this from the menu bar dropdown. Note that this only behaves
reliably in a properly exported build sitting in /Applications, not when
run directly from Xcode's debugger.

LICENCE
-------
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

AUTHOR
------
ClincialScript
