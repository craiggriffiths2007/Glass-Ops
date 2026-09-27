import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.app, required this.onShowRepair,
      required this.onShowAccount});
  final AppController app;
  final VoidCallback onShowRepair;
  final VoidCallback onShowAccount;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CustomerRepair? _repair;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await widget.app.repair(refresh: true);
      if (mounted) setState(() => _repair = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return GlassLoading(message: 'Loading your repair…');
    final name = widget.app.session.customerName.trim();
    final firstName = name.split(RegExp(r'\s+')).firstOrNull ?? 'Customer';
    final updates = [...?_repair?.updates]
      ..sort((a, b) => (b.dateTime ?? DateTime(0)).compareTo(a.dateTime ?? DateTime(0)));

    return RefreshIndicator(
      onRefresh: _load,
      child: PageScroll(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Eyebrow('GLASS OPS'),
            SizedBox(height: 17),
            Text('Welcome back', style: TextStyle(color: context.glass.muted, fontSize: 13)),
            SizedBox(height: 1),
            Text(firstName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          ])),
          IconButton.filledTonal(
            tooltip: 'My account',
            onPressed: widget.onShowAccount,
            icon: Text(initials(name), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
          ),
        ]),
        SizedBox(height: 29),
        if (_error != null)
          ErrorPanel(message: _error!, retry: _load)
        else if (_repair == null)
          GlassCard(child: Column(children: [
            Icon(Icons.window_outlined, color: context.glass.blue, size: 34),
            SizedBox(height: 12),
            Text('No repair available', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('There is no repair currently linked to this account.',
                textAlign: TextAlign.center, style: TextStyle(color: context.glass.muted)),
          ]))
        else ...[
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Eyebrow('YOUR REPAIR'),
            SizedBox(height: 15),
            Text(_repair!.addressLine1, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
            SizedBox(height: 3),
            Text('${_repair!.town} · ${_repair!.postcode}',
                style: TextStyle(color: context.glass.muted)),
            SizedBox(height: 26),
            if (_repair!.status == ContractStatus.cancelled)
              StatusPill('Repair cancelled', color: context.glass.coral)
            else
              _RepairProgress(stage: _repair!.progressStage),
            SizedBox(height: 26),
            DecoratedBox(
              decoration: BoxDecoration(
                  color: context.glass.panel, borderRadius: BorderRadius.circular(17)),
              child: Padding(
                padding: EdgeInsets.all(19),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Eyebrow('CURRENT STATUS', color: context.glass.muted),
                  SizedBox(height: 9),
                  Text(_repair!.statusTitle, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text(_repair!.statusDescription, style: TextStyle(color: context.glass.muted, height: 1.5)),
                  if (_repair!.statusEta.isNotEmpty) ...[
                    SizedBox(height: 14),
                    Row(children: [Icon(Icons.event_available_outlined, size: 17, color: context.glass.blue),
                      SizedBox(width: 7), Expanded(child: Text(_repair!.statusEta,
                        style: TextStyle(color: context.glass.blue, fontSize: 13)))])
                  ],
                ]),
              ),
            ),
            SizedBox(height: 21),
            GlassButton(label: 'View repair', onPressed: widget.onShowRepair,
                icon: Icons.arrow_forward_rounded),
          ])),
          if (updates.isNotEmpty) ...[
            SizedBox(height: 29),
            Text('Latest update', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 13),
            GlassCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(backgroundColor: context.glass.green.withValues(alpha: .16),
                  child: Icon(Icons.check, color: context.glass.green)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(updates.first.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text(updates.first.description, style: TextStyle(color: context.glass.muted, height: 1.5)),
                SizedBox(height: 10),
                Text(formatDate(updates.first.dateTime), style: TextStyle(color: context.glass.blue, fontSize: 12)),
              ])),
            ])),
          ],
        ],
      ]),
    );
  }
}

class _RepairProgress extends StatelessWidget {
  const _RepairProgress({required this.stage});
  final int stage;
  @override
  Widget build(BuildContext context) {
    const stages = ['Reported', 'Survey', 'Fitting', 'Complete'];
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < stages.length; i++) ...[
        Expanded(child: Column(children: [
          Container(
            width: 33, height: 33,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: i < stage ? context.glass.green : i == stage ? context.glass.blue : context.glass.border),
            child: Icon(i < stage ? Icons.check : Icons.circle,
                size: i < stage ? 19 : 9, color: i <= stage ? (Theme.of(context).brightness == Brightness.dark ? context.glass.night : Colors.white) : context.glass.muted),
          ),
          SizedBox(height: 8),
          Text(stages[i], textAlign: TextAlign.center,
            style: TextStyle(color: i <= stage ? context.glass.pale : context.glass.muted,
              fontSize: 11, fontWeight: i == stage ? FontWeight.w800 : FontWeight.w500)),
        ])),
        if (i < stages.length - 1)
          Expanded(child: Padding(padding: EdgeInsets.only(top: 15),
            child: Container(height: 3, color: i < stage ? context.glass.green : context.glass.border))),
      ],
    ]);
  }
}
