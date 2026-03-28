import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import AstalNotifd from "gi://AstalNotifd"
import Wp from "gi://AstalWp"
import { createBinding } from "ags"
import css from "./style.css"

const { VERTICAL } = Gtk.Orientation
const { TOP, RIGHT } = Astal.WindowAnchor
const { START, CENTER } = Gtk.Align

// ── Notification Center ──────────────────────────────────────────

function Notification({ n }: { n: AstalNotifd.Notification }) {
  return (
    <box class="notification" orientation={VERTICAL}>
      <box>
        <label class="app-name" halign={START} hexpand
          label={(n.appName || "Unknown").toUpperCase()} />
        <button class="close" onClicked={() => n.dismiss()}>
          <label label="x" />
        </button>
      </box>
      <box orientation={VERTICAL}>
        <label class="summary" halign={START} label={n.summary} wrap />
        {n.body && <label class="body" halign={START} label={n.body} wrap useMarkup />}
      </box>
      {n.get_actions().length > 0 && (
        <box class="actions">
          {n.get_actions().map(({ label, id }) => (
            <button hexpand label={label} onClicked={() => n.invoke(id)} />
          ))}
        </box>
      )}
    </box>
  )
}

function NotificationCenter() {
  const notifd = AstalNotifd.get_default()
  const notifications = createBinding(notifd, "notifications")

  return (
    <window
      name="notification-center"
      application={app}
      visible={false}
      anchor={TOP | RIGHT}
      class="notification-center"
    >
      <box orientation={VERTICAL} class="container">
        <box class="header">
          <label label="Notifications" hexpand halign={START} />
          <button label="Clear" onClicked={() => {
            for (const n of notifd.get_notifications()) n.dismiss()
          }} />
        </box>
        <Gtk.ScrolledWindow vexpand heightRequest={400}>
          <box orientation={VERTICAL} valign={START}>
            {notifications.as(ns => {
              if (ns.length === 0)
                return <label class="empty-label" label="No notifications" />
              return <box orientation={VERTICAL}>
                {ns.map(n => <Notification n={n} />)}
              </box>
            })}
          </box>
        </Gtk.ScrolledWindow>
      </box>
    </window>
  )
}

// ── Quick Settings ───────────────────────────────────────────────

function VolumeSlider() {
  const wp = Wp.get_default()!
  const speaker = wp.audio.default_speaker!
  const volume = createBinding(speaker, "volume")
  const mute = createBinding(speaker, "mute")

  return (
    <box class="volume-row">
      <button onClicked={() => { speaker.mute = !speaker.mute }}>
        <image iconName={mute.as(m =>
          m ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"
        )} />
      </button>
      <slider
        hexpand
        drawValue={false}
        value={volume}
        onNotifyValue={({ value }) => { speaker.volume = value }}
      />
    </box>
  )
}

function MicSlider() {
  const wp = Wp.get_default()!
  const mic = wp.audio.default_microphone!
  const volume = createBinding(mic, "volume")
  const mute = createBinding(mic, "mute")

  return (
    <box class="volume-row">
      <button onClicked={() => { mic.mute = !mic.mute }}>
        <image iconName={mute.as(m =>
          m ? "microphone-disabled-symbolic" : "microphone-sensitivity-high-symbolic"
        )} />
      </button>
      <slider
        hexpand
        drawValue={false}
        value={volume}
        onNotifyValue={({ value }) => { mic.volume = value }}
      />
    </box>
  )
}

function QuickSettings() {
  return (
    <window
      name="quicksettings"
      application={app}
      visible={false}
      anchor={TOP | RIGHT}
      class="quicksettings"
    >
      <box orientation={VERTICAL} class="container">
        <label class="section-label" halign={START} label="AUDIO" />
        <VolumeSlider />
        <MicSlider />
      </box>
    </window>
  )
}

// ── App Entry ────────────────────────────────────────────────────

app.start({
  instanceName: "popups",
  css,
  main() {
    const nc = NotificationCenter()
    const qs = QuickSettings()
    console.log("Windows created:", app.get_windows().map(w => w.name))
  },
  requestHandler(request: string | string[], res: (response: string) => void) {
    const cmd = Array.isArray(request) ? request[0] : String(request)
    for (const win of app.get_windows()) {
      if (win.name === cmd) {
        win.visible = !win.visible
        res("ok")
        return
      }
    }
    const names = app.get_windows().map(w => w.name)
    res(`no match for: ${cmd} (type: ${typeof request}), have: ${names}`)
  },
})
