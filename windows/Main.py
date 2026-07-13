"""
StrainAway - cross-platform 20-20-20 eye break reminder
Runs as a system tray / menu bar icon on both Windows and macOS.
"""

import sys
import threading
import platform
import asyncio
from pathlib import Path
import pystray
from PIL import Image
from desktop_notifier import DesktopNotifier
import darkdetect
import ctypes
import platform
import os

APP_NAME = "StrainAway"
INTERVAL_SECONDS = 2  # 20 minutes
ASSETS_DIR = Path(__file__).parent / "assets"

notifier = DesktopNotifier(app_name=APP_NAME)


class BreakTimer:
    def __init__(self):
        self.timer = None
        self.running = False
        self.loop = asyncio.new_event_loop()
        threading.Thread(target=self.loop.run_forever, daemon=True).start()

    def start(self):
        if self.running:
            return
        self.running = True
        self._schedule_next()

    def stop(self):
        self.running = False
        if self.timer:
            self.timer.cancel()
            self.timer = None

    def _schedule_next(self):
        if not self.running:
            return
        self.timer = threading.Timer(INTERVAL_SECONDS, self._fire)
        self.timer.daemon = True
        self.timer.start()

    def _fire(self):
        asyncio.run_coroutine_threadsafe(
            notifier.send(
                title="Time to take the strain away!",
                message="Look at something 20 feet away for 20 seconds.",
            ),
            self.loop,
        )
        self._schedule_next()


break_timer = BreakTimer()


# Launch at login

def is_launch_at_login_enabled() -> bool:
    system = platform.system()
    if system == "Windows":
        import winreg
        try:
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Run",
                0, winreg.KEY_READ,
            )
            winreg.QueryValueEx(key, APP_NAME)
            return True
        except FileNotFoundError:
            return False
    elif system == "Darwin":
        plist_path = Path.home() / "Library/LaunchAgents/com.strainaway.app.plist"
        return plist_path.exists()
    return False


def toggle_launch_at_login():
    system = platform.system()
    enabled = is_launch_at_login_enabled()

    if system == "Windows":
        import winreg
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0, winreg.KEY_SET_VALUE,
        )
        if enabled:
            winreg.DeleteValue(key, APP_NAME)
        else:
            exe_path = sys.executable
            winreg.SetValueEx(key, APP_NAME, 0, winreg.REG_SZ, exe_path)
        winreg.CloseKey(key)

    elif system == "Darwin":
        plist_path = Path.home() / "Library/LaunchAgents/com.strainaway.app.plist"
        if enabled:
            plist_path.unlink()
        else:
            plist_path.parent.mkdir(parents=True, exist_ok=True)
            exe_path = sys.executable
            plist_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.strainaway.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>{exe_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
"""
            plist_path.write_text(plist_content)


def create_start_menu_shortcut():
    import winshell
    from win32com.client import Dispatch

    start_menu = winshell.programs()
    shortcut_path = os.path.join(start_menu, "StrainAway.lnk")
    if not os.path.exists(shortcut_path):
        shell = Dispatch("WScript.Shell")
        shortcut = shell.CreateShortCut(shortcut_path)
        shortcut.TargetPath = sys.executable
        shortcut.IconLocation = str(ASSETS_DIR / "app_icon.ico")
        shortcut.save()

# Tray icon / menu


def load_icon() -> Image.Image:
    if darkdetect.isDark():
        icon_path = ASSETS_DIR / "tray_icon_white.png"
    else:
        icon_path = ASSETS_DIR / "tray_icon_black.png"
    return Image.open(icon_path)


def on_start_stop(icon, item):
    if break_timer.running:
        break_timer.stop()
    else:
        break_timer.start()
    icon.update_menu()


def on_toggle_launch(icon, item):
    toggle_launch_at_login()
    icon.update_menu()


def on_quit(icon, item):
    break_timer.stop()
    icon.stop()


def start_stop_label(item):
    return "Stop reminders" if break_timer.running else "Start reminders"


def launch_label(item):
    return "Disable launch at login" if is_launch_at_login_enabled() else "Enable launch at login"


def main():
    if platform.system() == "Windows":
        myappid = "strainaway.app.1.0"
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

    break_timer.start()

    menu = pystray.Menu(
        pystray.MenuItem(start_stop_label, on_start_stop),
        pystray.MenuItem(launch_label, on_toggle_launch),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Quit", on_quit),
    )

    icon = pystray.Icon(APP_NAME, load_icon(), APP_NAME, menu)
    icon.run()


if __name__ == "__main__":
    main()
