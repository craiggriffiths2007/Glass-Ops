import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Equivalent to the MAUI SecureStorage-backed CustomerSessionService.
class CustomerSession extends ChangeNotifier {
  CustomerSession({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _authKey = 'customer_authentication';
  static const _nameKey = 'customer_name';
  static const _customerKey = 'customer_id';
  static const _contractKey = 'customer_contract_id';

  bool _restored = false;
  String authenticationString = '';
  String customerName = '';
  int customerId = 0;
  int contractId = 0;
  bool get isLoggedIn => authenticationString.isNotEmpty;

  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      authenticationString = await _storage.read(key: _authKey) ?? '';
      customerName = await _storage.read(key: _nameKey) ?? '';
      customerId = int.tryParse(await _storage.read(key: _customerKey) ?? '') ?? 0;
      contractId = int.tryParse(await _storage.read(key: _contractKey) ?? '') ?? 0;
      if (authenticationString.isEmpty || contractId <= 0) _clear();
    } catch (_) {
      // Android restore or keystore changes can invalidate encrypted data.
      _clear();
    }
    notifyListeners();
  }

  Future<void> set({
    required String authentication,
    required String name,
    required int customer,
    required int contract,
  }) async {
    await _storage.write(key: _authKey, value: authentication);
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _customerKey, value: customer.toString());
    await _storage.write(key: _contractKey, value: contract.toString());
    authenticationString = authentication;
    customerName = name;
    customerId = customer;
    contractId = contract;
    _restored = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _clear();
    _restored = true;
    notifyListeners();
    try {
      await Future.wait([
        _storage.delete(key: _authKey),
        _storage.delete(key: _nameKey),
        _storage.delete(key: _customerKey),
        _storage.delete(key: _contractKey),
      ]);
    } catch (_) {
      // Already removed from memory, even if OS keychain is unavailable.
    }
  }

  void _clear() {
    authenticationString = '';
    customerName = '';
    customerId = 0;
    contractId = 0;
  }
}
