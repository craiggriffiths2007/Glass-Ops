import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlassColors {
  static const night = Color(0xFF07131F);
  static const navy = Color(0xFF10283A);
  static const surface = Color(0xFF172F40);
  static const blue = Color(0xFF52C2FF);
  static const blueStrong = Color(0xFF298ACC);
  static const pale = Color(0xFFECF7FC);
  static const muted = Color(0xFFA9BDCB);
  static const border = Color(0xFF355063);
  static const green = Color(0xFF62DCAD);
  static const coral = Color(0xFFFF9D8D);
}


/// App colours for both system appearances. Dark values preserve the original
/// Glass Ops design; light values use higher-contrast text and blue accents.
class GlassPalette {
  const GlassPalette({
    required this.night,
    required this.navy,
    required this.surface,
    required this.blue,
    required this.blueStrong,
    required this.pale,
    required this.muted,
    required this.border,
    required this.green,
    required this.coral,
    required this.card,
    required this.cardBorder,
    required this.cardShadow,
    required this.panel,
    required this.inputFill,
    required this.bubbleSent,
    required this.bubbleReceived,
  });

  final Color night, navy, surface, blue, blueStrong, pale, muted, border;
  final Color green, coral, card, cardBorder, cardShadow, panel, inputFill;
  final Color bubbleSent, bubbleReceived;

  static const dark = GlassPalette(
    night: GlassColors.night,
    navy: GlassColors.navy,
    surface: GlassColors.surface,
    blue: GlassColors.blue,
    blueStrong: GlassColors.blueStrong,
    pale: GlassColors.pale,
    muted: GlassColors.muted,
    border: GlassColors.border,
    green: GlassColors.green,
    coral: GlassColors.coral,
    card: Color(0x16FFFFFF),
    cardBorder: Color(0x21FFFFFF),
    cardShadow: Color(0x29000000),
    panel: Color(0xFF0C2030),
    inputFill: Color(0x13FFFFFF),
    bubbleSent: Color(0xFF20527A),
    bubbleReceived: Color(0xFF273F50),
  );

  static const light = GlassPalette(
    night: Color(0xFFF2F7FB),
    navy: Color(0xFFFFFFFF),
    surface: Color(0xFFEAF3F9),
    blue: Color(0xFF12649A),
    blueStrong: Color(0xFF145B8A),
    pale: Color(0xFF182F41),
    muted: Color(0xFF536A7B),
    border: Color(0xFFC7D7E2),
    green: Color(0xFF16734E),
    coral: Color(0xFFAF403F),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFD6E3EB),
    cardShadow: Color(0x140D3854),
    panel: Color(0xFFEAF4FB),
    inputFill: Color(0xFFFFFFFF),
    bubbleSent: Color(0xFFD9EFFD),
    bubbleReceived: Color(0xFFEAF1F5),
  );
}

/// Calling Theme.of here makes widgets rebuild with the OS appearance.
extension GlassThemeContext on BuildContext {
  GlassPalette get glass => Theme.of(this).brightness == Brightness.dark
      ? GlassPalette.dark
      : GlassPalette.light;
}

String formatDate(DateTime? date, [String pattern = 'd MMMM · HH:mm']) =>
    date == null ? 'To be confirmed' : DateFormat(pattern).format(date.toLocal());

String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
  return words.map((word) => word.substring(0, 1).toUpperCase()).join();
}

class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.85, -1.1),
            radius: 1.55,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF175075), Color(0xFF102B40), GlassColors.night]
                : const [Color(0xFFFFFFFF), Color(0xFFF2F8FC), Color(0xFFE8F1F8)],
            stops: const [0.0, 0.39, 1.0],
          ),
        ),
        child: SafeArea(child: child),
      );
}

class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.controller});
  final List<Widget> children;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      );
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(22)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: context.glass.cardBorder),
          borderRadius: BorderRadius.circular(24),
          color: context.glass.card,
          boxShadow: [BoxShadow(color: context.glass.cardShadow, blurRadius: 28, offset: const Offset(0, 12))],
        ),
        child: child,
      );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(color: color ?? context.glass.blue, fontSize: 11, letterSpacing: 2.1, fontWeight: FontWeight.w800),
      );
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key, this.subtitle});
  final String text;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle!, style: TextStyle(color: context.glass.muted, height: 1.5)),
          ],
        ],
      );
}

class GlassButton extends StatelessWidget {
  const GlassButton({super.key, required this.label, this.onPressed, this.busy = false, this.secondary = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool secondary;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: secondary
            ? OutlinedButton.icon(
                onPressed: busy ? null : onPressed,
                icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
                label: Text(label),
              )
            : FilledButton(
                onPressed: busy ? null : onPressed,
                child: busy
                    ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                        Text(label),
                      ]),
              ),
      );
}

class GlassField extends StatelessWidget {
  const GlassField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.hint,
    this.autofillHints,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final String? hint;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.glass.pale)),
          const SizedBox(height: 9),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            obscureText: obscure,
            maxLength: maxLength,
            autofillHints: autofillHints,
            validator: validator,
            decoration: InputDecoration(hintText: hint, suffixIcon: suffix, counterText: ''),
          ),
        ],
      );
}

class InlineNotice extends StatelessWidget {
  const InlineNotice(this.text, {super.key, this.success = false});
  final String text;
  final bool success;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (success ? context.glass.green : context.glass.coral).withValues(alpha: .13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: success ? context.glass.green : context.glass.coral, height: 1.4)),
      );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.glass.blue;
    return DecoratedBox(
      decoration: BoxDecoration(color: accent.withValues(alpha: .17), borderRadius: BorderRadius.circular(99)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Text(text, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class GlassLoading extends StatelessWidget {
  const GlassLoading({super.key, this.message = 'Loading…'});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: context.glass.muted)),
        ]),
      );
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, this.retry});
  final String message;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Unable to load', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 9),
          Text(message, style: TextStyle(color: context.glass.muted)),
          if (retry != null) ...[const SizedBox(height: 18), GlassButton(label: 'Try again', onPressed: retry)],
        ]),
      );
}
