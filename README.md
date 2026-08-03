# Facenticator

A two-factor authentication (2FA) app for iOS that guards your TOTP codes behind facial-gesture authentication built on ARKit.

Instead of a fingerprint or a passcode, you unlock your one-time codes by replaying a sequence of facial gestures the app captures with the TrueDepth camera.

## Features

- **TOTP authenticator:** stores and generates time-based one-time codes for your accounts, like a standard 2FA app.
- **Facial-gesture unlock:** register a personal sequence of facial gestures (ARKit) and replay it to unlock the vault.
- **Biometric fallback:** Face ID / Touch ID via LocalAuthentication.
- **Encrypted at rest:** secrets live in the Keychain, with an added encryption layer over stored data.
- **Access history:** a per-site log of authentication events.
- **Site management:** add and organize the accounts protected by the app.

## How it works

1. **Registration:** the user records a sequence of facial gestures. ARKit blend shapes capture each gesture and the app stores only a derived representation, never raw face data.
2. **Locked vault:** TOTP secrets are encrypted and kept in the Keychain; the app stays locked until the user authenticates.
3. **Verification:** to unlock, the user replays the gesture sequence. On a match, the vault decrypts and the current TOTP codes become available.

## Architecture

Feature-first layout over a shared core:

- `Core/Authentication`: gesture registration, biometric handling and TOTP generation.
- `Core/Security`: encryption of stored data.
- `Core/Storage`: Keychain and Core Data persistence.
- `Features/*`: SwiftUI views and view models (registration, sites, history, settings).

**Stack:** SwiftUI · ARKit · LocalAuthentication · Core Data · Keychain · TOTP.

## Status

Portfolio project, not distributed on the App Store.

## License

© 2025 Carlos Muñoz Fernández. All rights reserved. Source is available for review only; see [LICENSE](LICENSE).
