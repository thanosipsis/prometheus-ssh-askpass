# Prometheus SSH Askpass

A dark, blurred Quickshell SSH prompt that matches [Prometheus Polkit Agent](https://github.com/thanosipsis/prometheus-polkit-agent).

Tested with Quickshell 0.3.2 and Hyprland 0.56.2 on CachyOS/Arch. Source installation; no root access is needed to install the user files.

- Masked passphrase and security-key PIN entry.
- Allow/Deny prompts for SSH key-use confirmations and dismissible SSH notices.
- Enter to submit and Escape to cancel.
- Reuses existing KSSHAskPass private-key passphrases from an unlocked Secret Service keyring. Security-key PINs are always prompted for.
- Private Unix-socket response channel; no plaintext response files or response logging.

## Dependencies

Required: Python 3, Quickshell 0.3.2, Qt Quick Layouts, OpenSSH, and a Wayland compositor with layer-shell support. Hyprland is required for the supplied blur rules.

Optional: Python `secretstorage` (`python-secretstorage` on Arch) and an unlocked Secret Service keyring to reuse existing saved KSSHAskPass passphrases. This integration was verified with GNOME Keyring; direct KWallet access is not implemented. Fish and systemd are needed only for their respective examples.

The theme uses JetBrainsMono Nerd Font and SF Pro Text when installed, with Qt font fallback otherwise. Fonts are not included.

See [INSTALL.md](INSTALL.md), [SECURITY.md](SECURITY.md), and [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
