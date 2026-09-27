# Glass Ops Customer — Flutter for Android

A native-compiled Flutter/Dart recreation of the **Glass Ops Customer MAUI Blazor Hybrid app**, based on `GlassOps.Customer(8).zip` (27 September 2026). This is a real Flutter UI, **not a WebView** and not a wrapper around the Blazor site.

## Features converted

| Original Blazor page/service | Flutter implementation |
| --- | --- |
| Login.razor | Reference + email + password, validation, show/hide password |
| Home.razor | Repair progress, status, latest update, account shortcut |
| Repair.razor | Status, next appointment, items and repair history |
| Photos.razor | Filtered customer-approved photos, authenticated image POSTs, large photo viewer |
| Contact.razor | Ticket list, unread flags, new messages, conversation and replies |
| Account.razor | Account details, change password, sign out |
| CustomerSessionService | Encrypted storage using `flutter_secure_storage` |
| CustomerRepairState | In-memory repair cache; Home refreshes from the server |
| CustomerApiService | Same ASP.NET `Customer/*` endpoints and JSON payloads |

The original branding image and six demo SVGs are included. The layout recreates the original dark navy/blue visual treatment in Flutter Material 3. The bundled demo SVGs are only used as fallbacks for **explicitly labelled demo images**. Production photos come from the authorised server endpoint.

## Open in Visual Studio Code on Windows

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/mobile) (Flutter 3.35 or later), the **Flutter** and **Dart** VS Code extensions, and the Android SDK through Android Studio. Make sure `flutter doctor` is happy and your Android device is detected.
2. Extract this ZIP, open the **GlassOps.Customer.Flutter** folder in VS Code (the folder containing `pubspec.yaml`), then use its PowerShell terminal:

   ```powershell
   .\setup-windows.ps1
   ```

   If Windows blocks scripts, from a trusted copy of this folder run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
   ```

   The script generates a **proper Android project and Gradle wrapper for your installed Flutter SDK**, preserves the converted Dart app, sets the app label to `My Repair`, adds Internet permission for release builds, disables Android backup of credentials, downloads dependencies, and installs the bundled Glass Ops launcher icon.
3. Connect your Samsung tablet with USB debugging or open an Android emulator. Press **F5** in VS Code, or run:

   ```powershell
   flutter analyze
   flutter test
   flutter run
   ```

To build a release APK, use `flutter build apk --release`. For an app bundle, use `flutter build appbundle --release`. **Production releases need your own release keystore and Play Console configuration.**

**Why isn't `android/` already included?** This conversion environment does not include the Flutter SDK, and a hand-written Gradle wrapper could mismatch your installed version. The included setup script generates the official, version-compatible Android scaffold on your Windows machine. Flutter recognises this folder as a project as soon as you open it in VS Code.

## Server configuration

The app targets `https://glassops.co.uk/` by default. You don't need to modify the server for these existing endpoints:

- `POST /Customer/Login` — `Reference`, `Email`, `Password`
- `POST /Customer/CurrentRepair` — `AuthenticationString`, `ContractId`
- `POST /Customer/GetImage` — `AuthenticationString`, `ContractId`, `Filename` (binary image)
- `POST /Customer/Account` — `AuthenticationString`, `ContractId`
- `POST /Customer/ChangePassword` — `AuthenticationString`, `CurrentPassword`, `NewPassword`
- `POST /Customer/CreateTicket` — `AuthenticationString`, `ContractId`, `Subject`, `Message`
- `POST /Customer/Tickets` — `AuthenticationString`, `ContractId`
- `POST /Customer/Ticket` — `AuthenticationString`, `TicketId`
- `POST /Customer/ReplyToTicket` — `AuthenticationString`, `TicketId`, `Message`

For local testing with another server, pass a Dart environment setting:

```powershell
flutter run --dart-define=GLASSOPS_API_URL=https://your-test-server.example/
```

Avoid storing credentials or live auth tokens in source control. As in the MAUI app, users must receive their account/reference details from the glazing company. The Flutter app **does not derive or enumerate contract references**. SecureStorage data is not migrated from an installed MAUI app: customers will sign in again.

## Security and release notes

- Auth tokens are kept in the device's encrypted storage, not in plain preferences.
- Photo bytes are retrieved by authenticated HTTPS POST and held only in memory (never placed in a public image URL or disk cache).
- A `401` from an authenticated endpoint clears the session and returns to the login screen.
- Android backup is disabled by the setup script to avoid encrypted storage/Keystore restoration problems.
- The generated Android package identifier defaults to `uk.co.glassops.glassops_customer_flutter`, separate from your MAUI app's `uk.co.glassops.customer`. To **replace the existing Play Store app**, change the Android `applicationId` to the **exact existing ID**, use your existing Play App Signing/release setup, and follow Google's normal app update requirements. Do not use the original ID for an unrelated/test installation that you need side by side.
- The original source ZIP did **not** include `GlassOps.Shared` or server code. The API contracts above were converted from the Customer source; integration with a live test account still needs to be checked before release.
- The app has no local SQLite database or offline repair editing, matching this particular MAUI Customer source; repair data and messaging require internet access.

## Project layout

```text
lib/
  main.dart                    # authentication shell / bottom navigation / theme
  models/models.dart           # repair, account and ticket response DTOs
  services/                    # HTTP API, encrypted session, repair cache
  screens/                     # login, home, repair, photos, contact, account
  widgets/ui.dart              # shared dark Glass Ops components
assets/branding/               # Glass Ops icon and splash artwork
assets/demo/                   # six SVG demo photos
setup-windows.ps1               # generate native Android shell on Windows
test/models_test.dart           # JSON conversion tests
```
