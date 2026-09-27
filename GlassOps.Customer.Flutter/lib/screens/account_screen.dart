import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.app});
  final AppController app;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _replacement = TextEditingController();
  CustomerAccount? _account;
  bool _loading = true;
  bool _saving = false;
  String? _message;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    widget.app.session.addListener(_checkAuth);
    _load();
  }

  void _checkAuth() {
    if (!widget.app.session.isLoggedIn && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.app.session.removeListener(_checkAuth);
    _current.dispose();
    _replacement.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final account = await widget.app.api.getAccount();
      if (mounted) setState(() => _account = account);
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_form.currentState?.validate() ?? false) || _saving) return;
    setState(() { _saving = true; _message = null; });
    try {
      await widget.app.api.changePassword(_current.text, _replacement.text);
      _current.clear(); _replacement.clear();
      if (mounted) setState(() { _message = 'Your password has been changed.'; _success = true; });
    } catch (e) {
      if (mounted) setState(() { _message = e.toString(); _success = false; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    // Pop first so that the root auth transition can safely remove the shell.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await widget.app.logout();
  }

  Widget _accountRow(String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: context.glass.muted, fontSize: 12)),
          SizedBox(height: 5),
          Text(value.isEmpty ? '—' : value, style: TextStyle(fontWeight: FontWeight.w600)),
          Divider(height: 19, color: context.glass.border),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Backdrop(child: PageScroll(children: [
      Row(children: [
        IconButton.filledTonal(onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back), tooltip: 'Back'),
        SizedBox(width: 11),
        Text('My Account', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
      ]),
      SizedBox(height: 20),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: CircleAvatar(radius: 36, backgroundColor: context.glass.blueStrong,
            child: Text(initials(widget.app.session.customerName),
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white)))),
        SizedBox(height: 13),
        Text(widget.app.session.customerName, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        if (_loading)
          Padding(padding: EdgeInsets.all(22), child: GlassLoading(message: 'Loading account…'))
        else if (_account != null) ...[
          SizedBox(height: 22),
          _accountRow('Email', _account!.email),
          _accountRow('Address', [
            _account!.addressLine1,
            _account!.addressLine2,
            _account!.town,
            _account!.postcode,
          ].where((s) => s.isNotEmpty).join('\n')),
          _accountRow('Phone', _account!.phone),
        ],
      ])),
      SizedBox(height: 18),
      GlassCard(child: Form(key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 7),
            Text('Change the password you use to sign in to Glass Ops.',
                style: TextStyle(color: context.glass.muted)),
            SizedBox(height: 21),
            GlassField(label: 'Current password', controller: _current, obscure: true,
                validator: (s) => s == null || s.isEmpty ? 'Enter your current password' : null),
            SizedBox(height: 16),
            GlassField(label: 'New password', controller: _replacement, obscure: true,
                validator: (s) => s == null || s.length < 6 ? 'Password must be at least 6 characters.' : null),
            if (_message != null) ...[
              SizedBox(height: 17), InlineNotice(_message!, success: _success),
            ],
            SizedBox(height: 21),
            GlassButton(label: 'Change Password', busy: _saving, onPressed: _changePassword),
          ]))),
      SizedBox(height: 18),
      GlassCard(child: GlassButton(label: 'Sign out', secondary: true,
          icon: Icons.logout_rounded, onPressed: _signOut)),
    ])),
  );
}
