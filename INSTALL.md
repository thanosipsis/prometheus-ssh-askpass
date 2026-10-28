# Install

Copy the user files from the repository:

```sh
install -Dm755 bin/prometheus-askpass "$HOME/.local/bin/prometheus-askpass"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
cp -R configs/prometheus-askpass "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/"
```

Back up an existing `prometheus-askpass` configuration before copying over it.

## Fish terminal SSH

Install the supplied snippet:

```sh
install -Dm644 examples/prometheus-askpass.fish \
  "${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/prometheus-askpass.fish"
```

Open a new terminal, or run this in an existing Fish terminal:

```fish
source "$__fish_config_dir/conf.d/prometheus-askpass.fish"
ssh your-host
```

For Bash/Zsh, export these variables in your interactive graphical shell setup:

```sh
export SSH_ASKPASS="$HOME/.local/bin/prometheus-askpass"
export SSH_ASKPASS_REQUIRE=force
```

SSH normally uses the terminal when one is available. `force` selects the graphical prompt even from a terminal. Scope these settings to graphical sessions so headless sessions can continue to use their terminal.

## Existing systemd SSH agent

If your agent performs key-use confirmations or security-key authentication, it also needs `SSH_ASKPASS` in its own environment. Add this drop-in to your existing agent's user service, replacing `your-agent.service` with its actual unit name:

```sh
systemctl --user edit your-agent.service
```

```ini
[Service]
Environment=SSH_ASKPASS=%h/.local/bin/prometheus-askpass
Environment=SSH_ASKPASS_REQUIRE=force
```

Import the graphical environment, then restart that service:

```sh
systemctl --user import-environment WAYLAND_DISPLAY DISPLAY
systemctl --user daemon-reload
systemctl --user restart your-agent.service
```

**Restarting ssh-agent clears its in-memory keys.** Reload them through your normal SSH workflow. This project does not create a new agent or change SSH identities.

## Hyprland blur

Add the rules in [examples/hyprland-blur.lua](examples/hyprland-blur.lua) to your Lua configuration, then run `hyprctl reload`. They match the Prometheus polkit dialog's blur and alpha threshold. The separate dim layer remains a dark overlay.

For older Hyprland versions using legacy configuration syntax, translate the two rules using that version's layer-rule documentation.

## Existing saved passphrases

When Python `secretstorage` is installed, the adapter reads existing KSSHAskPass entries from unlocked Secret Service collections. The matched attributes are `server=ksshaskpass`, `xdg:schema=org.qt.keychain`, and `user=<absolute key path>`.

Only recognized private-key passphrase requests are eligible. PINs, confirmations, and notices bypass the keyring. A repeated passphrase request from the same parent process bypasses the cached value in case it is stale. No new credentials are saved, and locked keyrings are not unlocked automatically.

## Preview and checks

Use dummy text for a manual preview; the response is discarded:

```sh
"$HOME/.local/bin/prometheus-askpass" 'Test passphrase prompt' >/dev/null
SSH_ASKPASS_PROMPT=confirm "$HOME/.local/bin/prometheus-askpass" 'Allow this test request?' >/dev/null
```

Static and cache-logic checks from the source tree:

```sh
python3 -m py_compile bin/prometheus-askpass
python3 -m unittest discover -s tests -v
/usr/lib/qt6/bin/qmllint configs/prometheus-askpass/shell.qml
```

`qmllint` may report dynamic PanelWindow/screen type warnings. Use the installed Quickshell runtime and a manual dummy preview to check actual rendering.

## Uninstall or recover

Restore your previous `SSH_ASKPASS` setting, remove the Fish snippet and the drop-in you added, and open a fresh terminal. For a systemd agent, reload its unit files and restart it after restoring the previous setting; this clears in-memory keys again.

Once no process uses the adapter, remove `~/.local/bin/prometheus-askpass` and the `quickshell/prometheus-askpass` configuration directory. Remove the two Hyprland rules and reload the compositor. Existing keyring credentials are unchanged.
