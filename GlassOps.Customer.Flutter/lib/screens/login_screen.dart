import 'package:flutter/material.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.app});
  final AppController app;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _reference = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false;
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    if (!(_form.currentState?.validate() ?? false) || _busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await widget.app.api.login(_reference.text, _email.text, _password.text);
      // The root listener automatically replaces the login screen with Home.
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _reference.dispose(); _email.dispose(); _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Backdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 25),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 455),
              child: GlassCard(
                padding: EdgeInsets.all(28),
                child: AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Image.asset('assets/branding/splash.png', height: 94, fit: BoxFit.contain),
                      SizedBox(height: 16),
                      Center(child: Eyebrow('GLASS OPS')),
                      SizedBox(height: 22),
                      Text('Track your repair', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                      SizedBox(height: 9),
                      Text('Sign in to see progress, appointments and updates for work at your property.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.glass.muted, height: 1.5)),
                      SizedBox(height: 28),
                      GlassField(
                        label: 'Reference', controller: _reference,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        hint: 'Your 8-digit reference',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter your reference' : null,
                      ),
                      SizedBox(height: 18),
                      GlassField(
                        label: 'Email address', controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                            ? 'Enter a valid email address' : null,
                      ),
                      SizedBox(height: 18),
                      GlassField(
                        label: 'Password', controller: _password,
                        obscure: !_visible,
                        autofillHints: const [AutofillHints.password],
                        suffix: TextButton(onPressed: () => setState(() => _visible = !_visible),
                            child: Text(_visible ? 'Hide' : 'Show')),
                        validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
                      ),
                      if (_error != null) ...[SizedBox(height: 17), InlineNotice(_error!)],
                      SizedBox(height: 24),
                      GlassButton(label: _busy ? 'Signing in…' : 'Sign in', busy: _busy, onPressed: _login),
                      SizedBox(height: 22),
                      Text('Your company will provide your Glass Ops login details.',
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.glass.muted)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
