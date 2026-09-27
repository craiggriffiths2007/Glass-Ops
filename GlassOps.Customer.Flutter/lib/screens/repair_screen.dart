import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key, required this.app, required this.onShowPhotos});
  final AppController app;
  final VoidCallback onShowPhotos;
  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  CustomerRepair? _repair;
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await widget.app.repair();
      if (mounted) setState(() => _repair = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return GlassLoading(message: 'Loading repair details…');
    if (_error != null) return PageScroll(children: [ErrorPanel(message: _error!, retry: _load)]);
    final repair = _repair;
    if (repair == null) return PageScroll(children: [GlassCard(child: Text('No repair is linked to this account.'))]);
    final ordered = [...repair.updates]
      ..sort((a, b) => (b.dateTime ?? DateTime(0)).compareTo(a.dateTime ?? DateTime(0)));
    final appt = repair.nextAppointment;
    return PageScroll(children: [
      Eyebrow('YOUR REPAIR'),
      SizedBox(height: 13),
      Row(children: [
        Expanded(child: PageTitle(repair.addressLine1, subtitle: '${repair.town} · ${repair.postcode}')),
        SizedBox(width: 7),
        StatusPill(repair.reference),
      ]),
      SizedBox(height: 28),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Eyebrow('CURRENT STATUS', color: context.glass.muted),
        SizedBox(height: 10),
        Text(repair.statusTitle, style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        SizedBox(height: 9),
        Text(repair.statusDescription, style: TextStyle(color: context.glass.muted, height: 1.5)),
        if (repair.statusEta.isNotEmpty) ...[
          SizedBox(height: 16),
          StatusPill(repair.statusEta),
        ],
      ])),
      if (appt != null) ...[
        SizedBox(height: 29),
        Eyebrow('NEXT APPOINTMENT'),
        SizedBox(height: 8),
        _SectionTitle(appt.type),
        SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 66, height: 72, alignment: Alignment.center,
              decoration: BoxDecoration(color: context.glass.blue.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(appt.dateTime == null ? '--' : DateFormat('dd').format(appt.dateTime!),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                Text(appt.dateTime == null ? 'TBC' : DateFormat('MMM').format(appt.dateTime!).toUpperCase(),
                    style: TextStyle(color: context.glass.blue, fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
            ),
            SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(formatDate(appt.dateTime, 'EEEE d MMMM'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text(formatDate(appt.dateTime, 'HH:mm'), style: TextStyle(color: context.glass.blue)),
            ])),
          ]),
          Divider(height: 33, color: context.glass.border),
          Text('Agent', style: TextStyle(color: context.glass.muted, fontSize: 12)),
          SizedBox(height: 5),
          Text(appt.engineerName, style: TextStyle(fontWeight: FontWeight.w700)),
          if (appt.notes.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(appt.notes, style: TextStyle(color: context.glass.muted)),
          ],
        ])),
      ],
      if (repair.items.isNotEmpty) ...[
        SizedBox(height: 32),
        Eyebrow('WORK BEING CARRIED OUT'),
        SizedBox(height: 8),
        const _SectionTitle('Repair items'),
        SizedBox(height: 13),
        for (final item in repair.items) ...[
          GlassCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.window_outlined, color: context.glass.blue, size: 27),
            SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Eyebrow(item.location, color: context.glass.muted),
              SizedBox(height: 6),
              Text(item.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text(item.description, style: TextStyle(color: context.glass.muted, height: 1.5)),
            ])),
          ])),
          SizedBox(height: 11),
        ],
      ],
      SizedBox(height: 26),
      Eyebrow('REPAIR HISTORY'),
      SizedBox(height: 8),
      const _SectionTitle('What has happened'),
      SizedBox(height: 14),
      if (ordered.isEmpty)
        GlassCard(child: Text('Updates about your repair will appear here.'))
      else
        for (final update in ordered) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: EdgeInsets.only(top: 7),
              child: Icon(update.isCurrent ? Icons.radio_button_checked : Icons.circle_outlined,
                size: 21, color: update.isCurrent ? context.glass.green : context.glass.muted)),
            SizedBox(width: 13),
            Expanded(child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(formatDate(update.dateTime), style: TextStyle(color: context.glass.blue, fontSize: 12)),
              SizedBox(height: 7),
              Text(update.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              SizedBox(height: 6),
              Text(update.description, style: TextStyle(color: context.glass.muted, height: 1.5)),
            ]))),
          ]),
          SizedBox(height: 12),
        ],
      SizedBox(height: 20),
      GlassButton(label: 'View repair photos', secondary: true,
        icon: Icons.photo_library_outlined, onPressed: widget.onShowPhotos),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700));
}
