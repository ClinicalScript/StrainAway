# StrainAway ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A minimalist macOS menu bar app that reminds you to follow the 20-20-20 rule by default or a custom
reminder interval of your choosing to help reduce digital eye strain (DES).

A Windows version of this app is also available — See the [windows README.md](../windows/README.md) file for setup and build instructions.

**Disclaimer: This application is a general wellness tool designed to encourage ergonomic screen breaks. It does not provide medical advice, diagnosis, or treatment. The 20-20-20 guidance is a general habit recommendation and should not replace professional ophthalmic or medical consultation.**

# FEATURES

- Lives quietly in the menu bar, no Dock icon
- Sends a native macOS notification every 20 minutes or at an interval of your choosing
- Start/stop reminders from the menu bar dropdown
- Optional "launch at login" toggle, so it starts automatically on boot
- Custom app icon and menu bar glyph, with light and dark mode variants

# REQUIREMENTS

- macOS Tahoe (26) or later
- Xcode 26 or later, if building from source

# BUILDING FROM SOURCE

1. Clone this repository.
2. Open the .xcodeproj file in Xcode (available from the App Store on macOS).
3. Select the app target and press Cmd+R to build and run.
4. To create a standalone copy that runs without Xcode open:
   Product menu -> Archive -> Distribute App -> Copy App.
   Drag the exported .app into /Applications.

# FIRST LAUNCH

- macOS will ask for notification permission the first time the app runs.
  Click Allow, or reminders will not appear. It is recommended to set these notifications
  from temporary to persistent, System Settings > Notifications > StrainAway > toggle Altert Style to Persistent
- Since this app is not notarised through the Apple Developer Program,
  Gatekeeper may block it as being from an unidentified developer if
  downloaded rather than built locally. Right-click the app and choose
  Open, then confirm, to run it anyway.
- If you use a Focus or Do Not Disturb mode, add an exception for this
  app, or reminders will be silently suppressed while it's active.

# LAUNCH AT LOGIN

Toggle this from the menu bar dropdown. Note that this only behaves
reliably in a properly exported build sitting in /Applications, not when
run directly from Xcode's debugger.

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

This project is licensed under the MIT License — see the [LICENSE](../LICENSE) file for details.

# FURTHER READING ON THE 20-20-20 RULE AND CUSTOM INTERVALS TO HELP REDUCE DIGITAL EYE STRAIN (DES)

[Deconstructing the 20-20-20 rule for digital eye strain](https://www.optometrytimes.com/view/deconstructing-20-20-20-rule-digital-eye-strain) — Optometry Times

[Research suggesting custom time intervals (available on macOS-v1.1) may be superior to the 20-20-20 rule](https://www.sciencedirect.com/science/article/abs/pii/S0014483525002349?via%3Dihub) - Science Direct (Elsevier)

# AUTHOR
ClincialScript

This project — primarily the code — was built with the
*assistance* of Claude (Anthropic) and Gemini (Google).
