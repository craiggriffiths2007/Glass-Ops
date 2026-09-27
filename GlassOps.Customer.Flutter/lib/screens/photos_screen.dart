import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key, required this.app});
  final AppController app;
  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const categories = ['All', 'Survey', 'Parts', 'Fitting', 'Completed'];
  final Map<String, Future<Uint8List?>> _photoRequests = {};
  CustomerRepair? _repair;
  String _category = 'All';
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repair = await widget.app.repair();
      if (!mounted) return;
      // Load on demand rather than downloading every protected photo at once.
      setState(() { _repair = repair; _photoRequests.clear(); });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Uint8List?> _image(String url) =>
      _photoRequests.putIfAbsent(url, () => widget.app.api.getCustomerImage(url));

  Widget _photoImage(CustomerPhoto photo, {BoxFit fit = BoxFit.cover}) {
    // The original MAUI project's SVGs are demo artwork, not server photos.
    final demoName = photo.url.replaceAll('\\', '/').split('/').last;
    final isDemo = photo.url.contains('images/demo/') && demoName.endsWith('.svg');
    return FutureBuilder<Uint8List?>(
      future: _image(photo.url),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: fit, width: double.infinity,
              errorBuilder: (_, _, _) => _PhotoPlaceholder());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        // Only offer the bundled artwork for the explicitly marked demo SVGs.
        if (isDemo) return SvgPicture.asset('assets/demo/$demoName', fit: fit);
        return _PhotoPlaceholder();
      },
    );
  }

  void _openPhoto(CustomerPhoto photo) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        backgroundColor: context.glass.navy,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              SizedBox(width: 15),
              Expanded(child: Text(photo.category, style: TextStyle(color: context.glass.blue))),
              IconButton(onPressed: () => Navigator.pop(dialogContext), icon: Icon(Icons.close), tooltip: 'Close'),
            ]),
            ConstrainedBox(constraints: BoxConstraints(maxHeight: 480, minHeight: 180),
                child: _photoImage(photo, fit: BoxFit.contain)),
            Padding(padding: EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(formatDate(photo.dateTime, 'd MMMM yyyy · HH:mm'),
                  style: TextStyle(color: context.glass.blue, fontSize: 12)),
                SizedBox(height: 7),
                Text(photo.title, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
                SizedBox(height: 7),
                Text(photo.description, style: TextStyle(color: context.glass.muted, height: 1.5)),
              ]),
            ),
          ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return GlassLoading(message: 'Loading photos…');
    if (_error != null) return PageScroll(children: [ErrorPanel(message: _error!, retry: _load)]);
    if (_repair == null) return PageScroll(children: [GlassCard(child: Text('No repair is linked to this account.'))]);
    final visible = _repair!.photos.where((p) => _category == 'All' || p.category == _category).toList()
      ..sort((a, b) => (b.dateTime ?? DateTime(0)).compareTo(a.dateTime ?? DateTime(0)));

    return PageScroll(children: [
      Eyebrow('YOUR REPAIR'),
      SizedBox(height: 12),
      Row(children: [
        Expanded(child: PageTitle('Photos',
            subtitle: 'Photos shared during your repair, from survey through to completion.')),
        StatusPill('${visible.length} photo${visible.length == 1 ? '' : 's'}'),
      ]),
      SizedBox(height: 23),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final category in categories) ...[
            ChoiceChip(
              label: Text(category),
              selected: _category == category,
              onSelected: (_) => setState(() => _category = category),
              selectedColor: context.glass.blue.withValues(alpha: .22),
              side: BorderSide(color: context.glass.border),
            ),
            SizedBox(width: 7),
          ],
        ]),
      ),
      SizedBox(height: 19),
      if (visible.isEmpty)
        GlassCard(child: Column(children: [
          Icon(Icons.photo_library_outlined, size: 35, color: context.glass.blue),
          SizedBox(height: 10), Text('No photos'),
        ]))
      else
        LayoutBuilder(builder: (context, size) {
          final columns = size.maxWidth > 470 ? 3 : 2;
          final width = (size.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final photo in visible)
              SizedBox(width: width,
                child: InkWell(
                  onTap: () => _openPhoto(photo),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: context.glass.surface, border: Border.all(color: context.glass.border),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AspectRatio(aspectRatio: 1.12, child: Stack(fit: StackFit.expand, children: [
                        _photoImage(photo),
                        Positioned(left: 8, bottom: 8, child: StatusPill(photo.category)),
                        Positioned(right: 8, top: 8,
                            child: Icon(Icons.open_in_full_rounded, color: Colors.white, size: 17)),
                      ])),
                      Padding(padding: EdgeInsets.all(11), child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(photo.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(height: 5),
                          Text(formatDate(photo.dateTime, 'd MMM · HH:mm'),
                            style: TextStyle(color: context.glass.muted, fontSize: 11)),
                        ],
                      )),
                    ]),
                  ),
                ),
              ),
          ]);
        }),
      SizedBox(height: 24),
      GlassCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 21, color: context.glass.blue),
        SizedBox(width: 11),
        Expanded(child: Text('Only photos approved for customer viewing are shown here. Internal job photos remain private.',
            style: TextStyle(fontSize: 12, color: context.glass.muted, height: 1.5))),
      ])),
    ]);
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  _PhotoPlaceholder();
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.glass.surface,
        child: Center(child: Icon(Icons.broken_image_outlined, size: 30, color: context.glass.muted)),
      );
}
