#!/usr/bin/env python3
"""Drive notification integration checks on a dedicated Android emulator."""
import pathlib
import subprocess
import threading
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "audit/request-implementation/android-notifications"
OUT.mkdir(parents=True, exist_ok=True)
PACKAGE = "com.example.workout_tracker"
ADB = ["adb", "-s", "emulator-5554"]


def adb(*args, **kwargs):
    return subprocess.run(ADB + list(args), check=True, **kwargs)


def capture(state):
    if state == "locked":
        policy = adb("shell", "dumpsys", "window", "policy", capture_output=True, text=True).stdout
        (OUT / "locked-policy.txt").write_text(policy)
        if "showing=true" not in policy:
            raise RuntimeError("Keyguard was not showing during the locked-screen check.")
    dump = adb("shell", "dumpsys", "notification", "--noredact",
               capture_output=True, text=True).stdout
    (OUT / f"{state}-notifications.txt").write_text(dump)
    if state != "locked":
        adb("shell", "cmd", "statusbar", "expand-notifications")
    else:
        adb("shell", "input", "keyevent", "224")  # wake, keep keyguard
    time.sleep(2)
    with (OUT / f"{state}.png").open("wb") as image:
        adb("exec-out", "screencap", "-p", stdout=image)
    adb("shell", "cmd", "statusbar", "collapse")
    if state == "locked":
        adb("shell", "input", "keyevent", "82")
    adb("shell", "am", "start", "-n", PACKAGE + "/.MainActivity",
        stdout=subprocess.DEVNULL)


def watch():
    seen = set()
    with (OUT / "integration.log").open() as log:
        while True:
            line = log.readline()
            if not line:
                time.sleep(.1)
                continue
            if "REST_QA:" not in line:
                continue
            state = line.split("REST_QA:", 1)[1].strip()
            if state in seen:
                continue
            seen.add(state)
            print(state, flush=True)
            if state == "denied-initial":
                adb("shell", "pm", "set-permission-flags", PACKAGE,
                    "android.permission.POST_NOTIFICATIONS", "user-fixed")
            elif state == "permissions":
                adb("shell", "pm", "clear-permission-flags", PACKAGE,
                    "android.permission.POST_NOTIFICATIONS", "user-fixed")
                adb("shell", "appops", "set", PACKAGE, "POST_NOTIFICATION", "allow")
                adb("shell", "pm", "grant", PACKAGE, "android.permission.POST_NOTIFICATIONS")
                adb("shell", "appops", "set", PACKAGE, "SCHEDULE_EXACT_ALARM", "allow")
            elif state in ("foreground", "background", "locked"):
                if state == "background":
                    adb("shell", "input", "keyevent", "3")
                if state == "locked":
                    adb("shell", "input", "keyevent", "223")
                time.sleep(7)
                capture(state)
            elif state == "denied":
                adb("shell", "appops", "set", PACKAGE, "POST_NOTIFICATION", "ignore")
            elif state == "done":
                adb("shell", "appops", "set", PACKAGE, "POST_NOTIFICATION", "allow")
                return


if __name__ == "__main__":
    devices = adb("devices", capture_output=True, text=True).stdout
    if "emulator-5554\tdevice" not in devices:
        raise SystemExit("Start a dedicated emulator-5554 before running this check.")
    adb("shell", "locksettings", "set-disabled", "false")
    adb("shell", "input", "keyevent", "82")
    adb("logcat", "-c")
    (OUT / "integration.log").write_text("")
    worker = threading.Thread(target=watch, daemon=True)
    worker.start()
    with (OUT / "integration.log").open("w") as log:
        result = subprocess.run(
            ["flutter", "test", "integration_test/notification_delivery_test.dart",
             "-d", "emulator-5554", "--reporter", "expanded"],
            cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    worker.join(timeout=2)
    print(f"Integration exit: {result.returncode}; evidence: {OUT}", flush=True)
    raise SystemExit(result.returncode)
