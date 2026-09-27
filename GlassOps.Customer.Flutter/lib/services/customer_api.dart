import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'customer_session.dart';

/// Keep this pointed at the existing ASP.NET server; never embed credentials.
const glassOpsBaseUrl = String.fromEnvironment(
  'GLASSOPS_API_URL',
  defaultValue: 'https://glassops.co.uk/',
);

class CustomerApiException implements Exception {
  const CustomerApiException(this.message, {this.unauthorized = false});
  final String message;
  final bool unauthorized;
  @override
  String toString() => message;
}

class CustomerApi {
  CustomerApi(this.session, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final CustomerSession session;
  final http.Client _http;
  Uri _endpoint(String path) => Uri.parse(glassOpsBaseUrl).resolve(path);

  Future<http.Response> _post(String path, Map<String, dynamic> payload, {bool signingIn = false}) async {
    try {
      final response = await _http.post(
        _endpoint(path),
        headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 25));
      if (response.statusCode == 401) {
        if (signingIn) {
          throw CustomerApiException(_readReason(response, 'Incorrect reference, email or password.'));
        }
        await session.logout();
        throw const CustomerApiException(
          'Your session has expired. Please sign in again.',
          unauthorized: true,
        );
      }
      return response;
    } on CustomerApiException {
      rethrow;
    } catch (_) {
      throw const CustomerApiException(
        'Unable to contact Glass Ops. Check your internet connection and try again.',
      );
    }
  }

  Map<String, dynamic> _payload({bool includeContract = true}) => {
        'AuthenticationString': session.authenticationString,
        if (includeContract) 'ContractId': session.contractId,
      };

  String _readReason(http.Response response, String fallback) {
    try {
      final raw = jsonDecode(utf8.decode(response.bodyBytes));
      if (raw is Map) {
        final reason = jsonString(Map<String, dynamic>.from(raw), 'reasonPhrase');
        if (reason.trim().isNotEmpty) return reason;
      }
    } catch (_) {}
    return fallback;
  }

  Map<String, dynamic> _object(http.Response response) {
    try {
      final raw = jsonDecode(utf8.decode(response.bodyBytes));
      if (raw is Map) return Map<String, dynamic>.from(raw);
    } catch (_) {}
    throw const CustomerApiException('The server returned an invalid response.');
  }

  void _requireSuccess(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CustomerApiException(_readReason(response, message));
    }
  }

  Future<CustomerLoginResult> login(String reference, String email, String password) async {
    final response = await _post('Customer/Login', {
      'Reference': reference.trim(),
      'Email': email.trim(),
      'Password': password,
    }, signingIn: true);
    _requireSuccess(response, 'Login failed. Check your details and try again.');
    final login = CustomerLoginResult.fromJson(_object(response));
    if (login.authenticationString.isEmpty || login.contractId <= 0) {
      throw const CustomerApiException('The server returned an invalid login response.');
    }
    await session.set(
      authentication: login.authenticationString,
      name: login.customerName,
      customer: login.customerId,
      contract: login.contractId,
    );
    return login;
  }

  Future<CustomerRepair?> getCurrentRepair() async {
    if (!session.isLoggedIn) return null;
    final response = await _post('Customer/CurrentRepair', _payload());
    if (response.statusCode == 404) return null;
    _requireSuccess(response, 'Unable to load repair details.');
    return CustomerRepair.fromJson(_object(response));
  }

  /// Protected endpoint: the auth string travels only in the HTTPS POST body.
  /// Do NOT use Image.network on unprotected /images/{filename} URLs.
  Future<Uint8List?> getCustomerImage(String urlOrFilename) async {
    if (!session.isLoggedIn) return null;
    final uri = Uri.tryParse(urlOrFilename);
    final rawPath = uri?.path ?? urlOrFilename;
    final filename = rawPath.replaceAll('\\', '/').split('/').last;
    if (filename.trim().isEmpty || filename == '.' || filename == '..') return null;
    try {
      final response = await _post('Customer/GetImage', {
        ..._payload(),
        'Filename': filename,
      });
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final contentType = response.headers['content-type'];
      if (contentType != null &&
          !contentType.toLowerCase().startsWith('image/') &&
          !contentType.toLowerCase().startsWith('application/octet-stream')) {
        return null;
      }
      return response.bodyBytes;
    } on CustomerApiException catch (e) {
      if (e.unauthorized) rethrow;
      return null;
    }
  }

  Future<CustomerAccount?> getAccount() async {
    final response = await _post('Customer/Account', _payload());
    if (response.statusCode == 404) return null;
    _requireSuccess(response, 'Unable to load account details.');
    return CustomerAccount.fromJson(_object(response));
  }

  Future<void> changePassword(String current, String replacement) async {
    final response = await _post('Customer/ChangePassword', {
      ..._payload(includeContract: false),
      'CurrentPassword': current,
      'NewPassword': replacement,
    });
    _requireSuccess(response, 'Unable to change password.');
  }

  Future<int> createTicket({required int contractId, required String subject, required String message}) async {
    final response = await _post('Customer/CreateTicket', {
      ..._payload(includeContract: false),
      'ContractId': contractId,
      'Subject': subject.trim(),
      'Message': message.trim(),
    });
    _requireSuccess(response, 'Unable to send your message.');
    return jsonInt(_object(response), 'ticketId');
  }

  Future<List<CustomerTicketListItem>> getTickets() async {
    final response = await _post('Customer/Tickets', _payload());
    _requireSuccess(response, 'Unable to load your messages.');
    try {
      final raw = jsonDecode(utf8.decode(response.bodyBytes));
      if (raw is List) {
        return raw.whereType<Map>().map((e) =>
            CustomerTicketListItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    throw const CustomerApiException('The server returned an invalid message list.');
  }

  Future<CustomerTicket> getTicket(int ticketId) async {
    final response = await _post('Customer/Ticket', {
      ..._payload(includeContract: false),
      'TicketId': ticketId,
    });
    _requireSuccess(response, 'Unable to open your message.');
    return CustomerTicket.fromJson(_object(response));
  }

  Future<void> replyToTicket(int ticketId, String message) async {
    final response = await _post('Customer/ReplyToTicket', {
      ..._payload(includeContract: false),
      'TicketId': ticketId,
      'Message': message.trim(),
    });
    _requireSuccess(response, 'Unable to send your reply.');
  }

  void dispose() => _http.close();
}
