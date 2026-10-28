# Security

This adapter handles authentication responses. Review the source before installing it.

- Responses travel from Quickshell to the adapter over a Unix socket in a private 0700 runtime directory. The adapter checks the connecting user's UID.
- Only the response is written to the calling OpenSSH process's stdout. Quickshell stdout/stderr are discarded. No plaintext response files are created.
- Core dumps are disabled for the adapter and inherited child. Secret data still exists briefly in process memory; Python/Qt cannot guarantee zeroization.
- The socket is user-isolated, not protected from other processes already running as the same user. Trust your session, compositor, configuration, and executable paths.
- Cancellation, malformed replies, a closed/crashed dialog, and a ten-minute deadline fail closed. The adapter terminates its child and removes its temporary socket directory.
- Existing private-key passphrases can be read from unlocked Secret Service collections. PINs are never retrieved or saved. No credentials are written or deleted by this project.
- Runtime cache-use markers contain parent-process identifiers and a key-path hash, never the passphrase. Old markers are pruned after one day during later cache lookups.
- Quickshell file watching is disabled during each request. The dialog displays request text as plain text.

Do not include credentials, private keys, keyring databases, or sensitive SSH prompts in bug reports. Use dummy requests to reproduce rendering problems.
