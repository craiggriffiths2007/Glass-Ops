import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key, required this.app});
  final AppController app;
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _reply = TextEditingController();
  CustomerRepair? _repair;
  List<CustomerTicketListItem> _tickets = [];
  CustomerTicket? _selected;
  bool _loading = true;
  bool _opening = false;
  bool _sending = false;
  bool _replying = false;
  String? _error;
  String? _sendNotice;
  String? _replyError;
  bool _sendSuccess = false;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _subject.dispose(); _message.dispose(); _reply.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repair = await widget.app.repair();
      final tickets = repair == null ? <CustomerTicketListItem>[] : await widget.app.api.getTickets();
      if (mounted) setState(() { _repair = repair; _tickets = tickets; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openTicket(int ticketId) async {
    if (_opening) return;
    setState(() { _opening = true; _error = null; });
    try {
      final ticket = await widget.app.api.getTicket(ticketId);
      if (!mounted) return;
      setState(() { _selected = ticket; _reply.clear(); _replyError = null; });
      final refreshed = await widget.app.api.getTickets(); // refresh unread state
      if (mounted) setState(() => _tickets = refreshed);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _createTicket() async {
    if (_sending || _repair == null) return;
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) {
      setState(() { _sendNotice = _subject.text.trim().isEmpty
          ? 'Please enter a subject.' : 'Please enter a message.'; _sendSuccess = false; });
      return;
    }
    setState(() { _sending = true; _sendNotice = null; });
    try {
      final ticketId = await widget.app.api.createTicket(
        contractId: _repair!.contractId,
        subject: _subject.text, message: _message.text,
      );
      _subject.clear(); _message.clear();
      if (!mounted) return;
      setState(() { _sendNotice = 'Your message has been sent.'; _sendSuccess = true; });
      final tickets = await widget.app.api.getTickets();
      if (mounted) setState(() => _tickets = tickets);
      if (ticketId > 0 && mounted) await _openTicket(ticketId);
    } catch (e) {
      if (mounted) setState(() { _sendNotice = e.toString(); _sendSuccess = false; });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendReply() async {
    if (_selected == null || _replying) return;
    if (_reply.text.trim().isEmpty) {
      setState(() => _replyError = 'Please enter a reply.');
      return;
    }
    setState(() { _replying = true; _replyError = null; });
    try {
      final ticketId = _selected!.id;
      await widget.app.api.replyToTicket(ticketId, _reply.text);
      _reply.clear();
      final updated = await widget.app.api.getTicket(ticketId);
      final tickets = await widget.app.api.getTickets();
      if (mounted) setState(() { _selected = updated; _tickets = tickets; });
    } catch (e) {
      if (mounted) setState(() => _replyError = e.toString());
    } finally {
      if (mounted) setState(() => _replying = false);
    }
  }

  Color _ticketColor(int status) => switch (status) {
        TicketStatus.awaitingCustomer => context.glass.coral,
        TicketStatus.awaitingOffice => context.glass.blue,
        TicketStatus.closed => context.glass.muted,
        _ => context.glass.green,
      };

  String _shortDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final today = DateTime.now();
    final day = DateTime(local.year, local.month, local.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    if (day == todayDate) return formatDate(local, 'HH:mm');
    if (day == todayDate.subtract(const Duration(days: 1))) return 'Yesterday';
    return formatDate(local, 'd MMM');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return GlassLoading(message: 'Loading your messages…');
    if (_error != null && _repair == null) {
      return PageScroll(children: [ErrorPanel(message: _error!, retry: _load)]);
    }
    if (_repair == null) {
      return PageScroll(children: [GlassCard(child: Text('No repair is linked to this account.'))]);
    }
    return PageScroll(children: [
      Eyebrow('NEED HELP?'),
      SizedBox(height: 10),
      PageTitle('Contact', subtitle: 'Send a message to the team handling your repair.'),
      SizedBox(height: 23),
      if (_error != null) ...[InlineNotice(_error!), SizedBox(height: 16)],
      if (_opening) LinearProgressIndicator(),
      if (_selected != null) _conversation(_selected!) else ...[
        if (_tickets.isNotEmpty) ...[
          Text('Your messages', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          for (final ticket in _tickets) ...[
            _ticketCard(ticket),
            SizedBox(height: 11),
          ],
          SizedBox(height: 18),
        ],
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Eyebrow('NEW MESSAGE'),
          SizedBox(height: 10),
          Text('How can we help?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Your message will be attached to repair ${_repair!.reference}.',
            style: TextStyle(color: context.glass.muted, height: 1.5)),
          SizedBox(height: 22),
          GlassField(label: 'Subject', controller: _subject, maxLength: 200,
              hint: 'What is your message about?'),
          SizedBox(height: 17),
          GlassField(label: 'Message', controller: _message, maxLines: 5,
              hint: 'Tell us how we can help…'),
          if (_sendNotice != null) ...[
            SizedBox(height: 17), InlineNotice(_sendNotice!, success: _sendSuccess),
          ],
          SizedBox(height: 23),
          GlassButton(label: 'Send message', busy: _sending, onPressed: _createTicket),
        ])),
      ],
    ]);
  }

  Widget _ticketCard(CustomerTicketListItem ticket) => InkWell(
        onTap: _opening ? null : () => _openTicket(ticket.id),
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(ticket.subject,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              if (ticket.hasUnreadMessages) ...[
                SizedBox(width: 8),
                CircleAvatar(radius: 4, backgroundColor: context.glass.blue),
              ],
            ]),
            SizedBox(height: 10),
            Wrap(spacing: 9, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
              StatusPill(TicketStatus.label(ticket.status), color: _ticketColor(ticket.status)),
              Text('${ticket.messageCount} ${ticket.messageCount == 1 ? 'message' : 'messages'}',
                style: TextStyle(color: context.glass.muted, fontSize: 12)),
            ]),
          ])),
          SizedBox(width: 10),
          Column(children: [
            Text(_shortDate(ticket.lastMessageDate ?? ticket.created),
                style: TextStyle(color: context.glass.muted, fontSize: 11)),
            SizedBox(height: 6),
            Icon(Icons.chevron_right, color: context.glass.blue),
          ]),
        ])),
      );

  Widget _conversation(CustomerTicket ticket) {
    final messages = [...ticket.messages]
      ..sort((a, b) => (a.created ?? DateTime(0)).compareTo(b.created ?? DateTime(0)));
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Eyebrow('CUSTOMER CONTACT'),
          SizedBox(height: 9),
          Text(ticket.subject, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
          SizedBox(height: 9),
          Align(alignment: Alignment.centerLeft,
            child: StatusPill(TicketStatus.label(ticket.status), color: _ticketColor(ticket.status))),
        ])),
        IconButton.filledTonal(
          tooltip: 'Back to messages',
          onPressed: () => setState(() { _selected = null; _reply.clear(); _replyError = null; }),
          icon: Icon(Icons.arrow_back),
        ),
      ]),
      SizedBox(height: 23),
      for (final message in messages) ...[
        Align(
          alignment: message.sender == 0 ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 390),
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: message.sender == 0 ? context.glass.bubbleSent : context.glass.bubbleReceived,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(message.sender == 0 ? 'You' :
                      message.senderName.isEmpty ? 'Glass Ops' : message.senderName,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: context.glass.blue)),
                SizedBox(height: 7),
                Text(message.message, style: TextStyle(height: 1.5)),
                SizedBox(height: 8),
                Text(formatDate(message.created, 'd MMM yyyy · HH:mm'),
                    style: TextStyle(color: context.glass.muted, fontSize: 11)),
              ]),
            ),
          ),
        ),
        SizedBox(height: 13),
      ],
      if (ticket.status == TicketStatus.closed)
        const InlineNotice('This conversation has been closed.', success: true)
      else ...[
        SizedBox(height: 12),
        GlassField(label: 'Reply', controller: _reply, maxLines: 4, hint: 'Type your reply…'),
        if (_replyError != null) ...[SizedBox(height: 12), InlineNotice(_replyError!)],
        SizedBox(height: 17),
        GlassButton(label: 'Send reply', busy: _replying, onPressed: _sendReply),
      ],
    ]));
  }
}
