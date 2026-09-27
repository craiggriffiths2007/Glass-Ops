import 'package:flutter/material.dart';

import 'screens/account_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/photos_screen.dart';
import 'screens/repair_screen.dart';
import 'services/app_controller.dart';
import 'widgets/ui.dart';

/// Reuse the same palettes used by the custom Glass Ops widgets.
ThemeData buildGlassTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark
      ? GlassPalette.dark
      : GlassPalette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.blue,
      brightness: brightness,
      primary: palette.blue,
      onPrimary: brightness == Brightness.dark ? GlassColors.night : Colors.white,
      surface: palette.navy,
      error: palette.coral,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 15, height: 1.4)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: palette.blue, width: 1.5),
      ),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlassOpsApp());
}

class GlassOpsApp extends StatefulWidget {
  const GlassOpsApp({super.key});
  @override
  State<GlassOpsApp> createState() => _GlassOpsAppState();
}

class _GlassOpsAppState extends State<GlassOpsApp> {
  late final AppController app = AppController();
  @override
  void initState() { super.initState(); app.initialize(); }
  @override
  void dispose() { app.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'My Repair',
        debugShowCheckedModeBanner: false,
        theme: buildGlassTheme(Brightness.light),
        darkTheme: buildGlassTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: AnimatedBuilder(
          animation: app,
          builder: (context, _) {
            if (!app.ready) {
              return const Scaffold(
                body: Backdrop(child: GlassLoading(message: 'Starting Glass Ops…')),
              );
            }
            return app.session.isLoggedIn
                ? CustomerShell(key: const ValueKey('logged-in'), app: app)
                : Scaffold(
                    body: LoginScreen(key: const ValueKey('logged-out'), app: app),
                  );
          },
        ),
      );
}

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.app});
  final AppController app;
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _tab = 0;
  int _pageRevision = 0;
  void _select(int tab) => setState(() { _tab = tab; _pageRevision++; });
  void _account() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AccountScreen(app: widget.app),
      ));

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      0 => HomeScreen(key: ValueKey('home-$_pageRevision'), app: widget.app,
          onShowRepair: () => _select(1), onShowAccount: _account),
      1 => RepairScreen(key: ValueKey('repair-$_pageRevision'), app: widget.app,
          onShowPhotos: () => _select(2)),
      2 => PhotosScreen(key: ValueKey('photos-$_pageRevision'), app: widget.app),
      _ => ContactScreen(key: ValueKey('contact-$_pageRevision'), app: widget.app),
    };
    return Scaffold(
      body: Backdrop(child: body),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: context.glass.navy,
            border: Border(top: BorderSide(color: context.glass.border, width: .5)),
          ),
          child: NavigationBar(
            height: 67,
            backgroundColor: Colors.transparent,
            indicatorColor: context.glass.blue.withValues(alpha: .18),
            selectedIndex: _tab,
            onDestinationSelected: _select,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Repair'),
              NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Photos'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Contact'),
            ],
          ),
        ),
      ),
    );
  }
}
