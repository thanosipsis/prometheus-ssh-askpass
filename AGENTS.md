# Agent instructions

Tested on CachyOS/Arch with Quickshell 0.3.2 and Hyprland 0.56.2.

- Never publish credentials, private keys, runtime state, keyring databases, or real authentication logs.
- Keep responses out of argv, environment variables, logs, and on-disk response files.
- Do not read or cache security-key PINs from a keyring.
- Run Python compile and unit checks before installation. Use dummy responses for runtime checks.
- Do not restart an existing SSH agent without accounting for its in-memory keys being cleared.
- Preserve the separate client-side and agent-side environment configuration.
