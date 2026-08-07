# Duress Password

A duress password lets you log in while under coercion without the other party knowing anything is wrong.

## How it Works
- Enter your normal password → normal session
- Enter your duress password → normal-looking login, but background scripts run
- Default action: securely wipes sensitive directories (~/.ssh, ~/.gnupg, ~/Documents, browser data, etc.)

## Setup
Run `hyprwave-assistant` → Knowledge Base or the dedicated `hyprwave-duress-setup` tool (once implemented).

You can add your own scripts in `~/.duress.d/`.

## Important
- Choose a password you will actually remember under stress
- The login experience is identical — this is by design
- Test it in a safe environment first

See the full Duress Password planning document for technical details.
