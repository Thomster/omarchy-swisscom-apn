import QtQuick
import Quickshell
import Quickshell.Io

// Headless: watches for a `gsm` device that NetworkManager can see but
// that has no matching Swisscom connection profile yet, and notifies you
// to run the bundled fix. Never creates the profile itself -- even though
// the fix script needs no root, a background service silently changing
// NetworkManager connection profiles on its own would be surprising, so
// this stays notify-only like the plugin's siblings.
Item {
  id: root

  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/swisscom-apn"
  readonly property string fixScript: pluginDir + "/bin/omarchy-swisscom-apn-fix"
  // Boot-scoped (tmpfs, cleared every boot/logout): a marker that outlived
  // its boot would permanently suppress the notification for a real future
  // regression (e.g. the profile getting deleted).
  readonly property string stateDir: Quickshell.env("XDG_RUNTIME_DIR") + "/omarchy/indicators"
  readonly property string neededMarker: stateDir + "/swisscom-apn-notified-needed"

  function runCheck() {
    if (checkProcess.running) return
    checkProcess.running = true
  }

  function notifyOnce(marker, title, body) {
    notifyProcess.command = ["bash", "-c",
      "mkdir -p " + JSON.stringify(root.stateDir) + "; " +
      "[[ -f " + JSON.stringify(marker) + " ]] && exit 0; " +
      "touch " + JSON.stringify(marker) + "; " +
      "omarchy-notification-send -u normal " + JSON.stringify(title) + " " + JSON.stringify(body)
    ]
    notifyProcess.running = true
  }

  Process {
    id: checkProcess
    command: ["bash", root.fixScript, "--check", "--quiet"]
    onExited: function(exitCode) {
      if (exitCode === 1) {
        root.notifyOnce(root.neededMarker,
          "Swisscom APN profile missing",
          "A gsm device is visible but has no connection profile. Run: " + root.fixScript)
      }
    }
  }

  Process {
    id: notifyProcess
  }

  Timer {
    // Shortly after shell start covers a modem already managed at login;
    // the slow periodic timer below catches ModemManager coming up later
    // (e.g. right after installing it), or the profile getting deleted.
    interval: 15000
    running: true
    repeat: false
    onTriggered: root.runCheck()
  }

  Timer {
    interval: 3600000
    running: true
    repeat: true
    onTriggered: root.runCheck()
  }
}
