# Glass Ops Customer — automatic light and dark themes

This update uses Flutter's ThemeMode.system. It follows the Android tablet's
Settings > Display > Dark mode option, and also responds to the system
appearance in browsers and on other platforms.

## Updating your existing working VS Code project

Copy/merge the `lib/` directory from the theme-patch ZIP into your existing
`GlassOps.Customer.Flutter` project. The files to overwrite are `lib/main.dart`,
`lib/widgets/ui.dart` and the six `lib/screens/*.dart` files. The patch also
contains `test/theme_test.dart` (optional). Keep your existing `android/`
folder, `pubspec.yaml`, signing settings, SDK locations and local changes
elsewhere. If you have edited the screens since the initial conversion, review
the changes before overwriting them.

With your Samsung tablet selected in VS Code, stop the running app and press
F5 for a full restart, or run `flutter run` in the project terminal. A full
restart is recommended when replacing the theme code.

To try both appearances: Settings > Display > Dark mode on your tablet.
No extra app settings or user account changes are required.

For a basic check, run:

    flutter analyze
    flutter test

The build and runtime tests must be run locally; this conversion environment
does not include the Flutter SDK.
