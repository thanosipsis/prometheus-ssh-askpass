# Apply only to interactive graphical sessions.
if status is-interactive
    if set -q WAYLAND_DISPLAY; or set -q DISPLAY
        set -gx SSH_ASKPASS "$HOME/.local/bin/prometheus-askpass"
        set -gx SSH_ASKPASS_REQUIRE force
    end
end
