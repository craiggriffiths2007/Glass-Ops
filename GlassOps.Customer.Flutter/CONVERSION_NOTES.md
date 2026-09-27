# Conversion notes

Source inspected: `GlassOps.Customer(8).zip` (MAUI .NET 10 + Blazor Hybrid). Only the Customer app source was supplied; it references a separate `GlassOps.Shared` project that was not present. Consequently, some enum definitions (including `ContractStatus`) were reconstructed from usage in the supplied pages and established customer status values. The UI and endpoint mappings follow the source. Test with a real demo account to confirm the live server's current response shapes.

**Differences:** Flutter uses native-compiled Dart and Material widgets instead of Blazor HTML/CSS. The status cards, dark navy theme, bottom navigation, photo filters, ticket conversation and profile have been recreated; minute-for-minute pixel equality with web CSS is not guaranteed. Images are fetched lazily rather than all at page load. Password fields are masked on the Flutter Account screen (the original web page used text inputs). Error reporting is surfaced rather than silently returning empty ticket lists. The original demo artwork is included as fallback only for demo-asset paths.

**Not claimed:** no `flutter analyze`, `flutter test`, Android build or live server sign-in could be run in the conversion environment because the Flutter SDK/Android SDK and a live test account are not available here. Run the included setup script first, then the documented checks in VS Code.
