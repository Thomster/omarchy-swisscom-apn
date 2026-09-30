# omarchy-swisscom-apn

An [Omarchy](https://omarchy.org/) shell service that ensures a
NetworkManager **GSM connection profile** exists for Swisscom's mobile
data APN (`gprs.swisscom.ch`), and notifies you to run the bundled fix if
it's missing.

Unlike Wi-Fi or Ethernet, NetworkManager never auto-creates a GSM
connection profile on its own — even once a modem is properly managed (see
[omarchy-fibocom-l830](https://github.com/Thomster/omarchy-fibocom-l830)),
`nmcli device status` will show a `gsm` device with nothing to actually
connect it to until a profile with the right APN exists.

No bar icon, no UI. It just watches for a `gsm` device with no matching
profile and sends one desktop notification per boot if it finds one,
pointing you at the bundled fix script — it never edits NetworkManager
state itself, even though the fix needs no root.

## The fix

```
omarchy-swisscom-apn-fix
```

Creates a `type gsm` connection profile named `Swisscom` with
`gsm.apn=gprs.swisscom.ch` and autoconnect on. No root needed —
NetworkManager lets the active session's user manage its own connection
profiles. It only creates the profile; it doesn't bring it up (that's left
to the GSM widget or [omarchy-network-priority](https://github.com/Thomster/omarchy-network-priority)'s
Ethernet/Wi-Fi-first enforcement).

## Install

```
omarchy plugin add https://github.com/Thomster/omarchy-swisscom-apn.git
```

## Usage

Once installed and enabled, it runs in the background and, if it detects
a `gsm` device with no Swisscom profile, sends a notification telling you
to run:

```
~/.config/omarchy/plugins/swisscom-apn/bin/omarchy-swisscom-apn-fix
```

You can also run the read-only check yourself any time:

```
~/.config/omarchy/plugins/swisscom-apn/bin/omarchy-swisscom-apn-fix --check
```

Exit code `0` means either the profile already exists or no `gsm` device
is visible yet; `1` means a `gsm` device exists but no matching profile
does.

## Requirements

- `nmcli` (NetworkManager)
- A managed WWAN modem exposed as a `gsm` device — see
  [omarchy-fibocom-l830](https://github.com/Thomster/omarchy-fibocom-l830)
  if `nmcli device status` doesn't show one yet
- A Swisscom SIM (this hardcodes Swisscom's public APN; a different
  carrier needs a different profile)

## Related

Pairs with [omarchy-fibocom-l830](https://github.com/Thomster/omarchy-fibocom-l830)
— that plugin gets the modem *managed*; this one gets it something to
*connect to*. Also composes with
[omarchy-network-priority](https://github.com/Thomster/omarchy-network-priority),
which keeps GSM deprioritized behind Ethernet and Wi-Fi once it can connect
at all.

## Changelog

Current version: **1.0.1**. See [CHANGELOG.md](CHANGELOG.md).

## How this came to be

This is a personal customization for my own Omarchy setup, built with the
help of [Claude Code](https://claude.com/claude-code) (Anthropic's AI coding
agent) while setting up mobile data on my own SIM. I'm not a professional
plugin developer — please read through the source before installing.

## License

MIT
