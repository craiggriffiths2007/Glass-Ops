import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassops_customer_flutter/main.dart';
import 'package:glassops_customer_flutter/widgets/ui.dart';

void main() {
  test('Both themes use appropriate contrast and the same Glass Ops layout', () {
    final light = buildGlassTheme(Brightness.light);
    final dark = buildGlassTheme(Brightness.dark);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.scaffoldBackgroundColor, GlassPalette.light.night);
    expect(dark.scaffoldBackgroundColor, GlassPalette.dark.night);
  });

  testWidgets('Shared cards switch palette with the Material theme', (tester) async {
    Future<void> show(ThemeData theme) => tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(body: Builder(builder: (context) => ColoredBox(
        key: const Key('themed-card'),
        color: context.glass.card,
        child: const Text('Glass Ops'),
      ))),
    ));

    await show(buildGlassTheme(Brightness.light));
    expect(tester.widget<ColoredBox>(find.byKey(const Key('themed-card'))).color,
        GlassPalette.light.card);

    await show(buildGlassTheme(Brightness.dark));
    expect(tester.widget<ColoredBox>(find.byKey(const Key('themed-card'))).color,
        GlassPalette.dark.card);
  });
}
