import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'customer_api.dart';
import 'customer_session.dart';

class AppController extends ChangeNotifier {
  AppController({CustomerSession? session, CustomerApi? api})
      : session = session ?? CustomerSession() {
    this.api = api ?? CustomerApi(this.session);
    this.session.addListener(_onSessionChanged);
  }
  final CustomerSession session;
  late final CustomerApi api;
  bool ready = false;
  CustomerRepair? _repair;

  void _onSessionChanged() {
    if (!session.isLoggedIn) _repair = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      await session.restore();
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<CustomerRepair?> repair({bool refresh = false}) async {
    if (!session.isLoggedIn) return null;
    if (_repair != null && !refresh) return _repair;
    final result = await api.getCurrentRepair();
    if (session.isLoggedIn) _repair = result;
    return result;
  }

  Future<void> logout() async {
    _repair = null;
    await session.logout();
  }

  @override
  void dispose() {
    session.removeListener(_onSessionChanged);
    api.dispose();
    session.dispose();
    super.dispose();
  }
}
