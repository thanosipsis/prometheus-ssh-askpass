# Troubleshooting

## SSH still asks in the terminal

The SSH client and ssh-agent have separate environments. Check `SSH_ASKPASS` and `SSH_ASKPASS_REQUIRE` in the terminal running SSH. Reload the Fish snippet or open a new terminal. Agent-side changes alone do not change the SSH client's environment.

## Passphrase is requested even though KSSHAskPass remembered it

Install Python `secretstorage` and ensure the Secret Service collection is already unlocked. Only existing QtKeychain/KSSHAskPass entries with an exact absolute key path are recognized. Direct KWallet lookup and saving new passphrases are not implemented. Repeated requests from the same SSH process intentionally bypass the cache.

## Security-key PIN is requested every time

This is intentional. Only the key-file passphrase is reused. PIN entry and any physical security-key touch remain part of the normal authentication flow.

## No dialog, or SSH reports askpass failed

Verify that Quickshell 0.3.2 can run in your graphical environment and that `XDG_RUNTIME_DIR` is writable. Run a dummy preview from INSTALL.md. Check that the config and its `theme/Theme.qml` were installed together. The adapter suppresses Quickshell logs to avoid recording authentication request details.

## Dark panel has no blur

Apply `examples/hyprland-blur.lua` to the active Hyprland Lua config and reload it. The dialog namespace is `prometheus-askpass`; the separate backdrop is `prometheus-askpass-dim`. Run `hyprctl configerrors` to check your compositor config.
