import 'package:flutter_test/flutter_test.dart';
import 'package:glassops_customer_flutter/models/models.dart';

void main() {
  group('Glass Ops ASP.NET JSON compatibility', () {
    test('login reads camelCase and PascalCase', () {
      final result = CustomerLoginResult.fromJson({
        'AuthenticationString': 'test-value', 'customerId': 12,
        'ContractId': 34, 'CustomerName': 'Test Customer',
      });
      expect(result.authenticationString, 'test-value');
      expect(result.customerId, 12);
      expect(result.contractId, 34);
      expect(result.customerName, 'Test Customer');
    });
    test('repair parses nested appointments and numeric status', () {
      final repair = CustomerRepair.fromJson({
        'ContractId': 8, 'Reference': '00123456',
        'AddressLine1': 'Example Street', 'Status': 2,
        'NextAppointment': {'Type': 'Fitting', 'DateTime': '2026-09-28T09:30:00'},
        'Updates': [{'Title': 'Survey done', 'IsCurrent': true,
          'DateTime': '2026-09-26T10:00:00'}],
        'Photos': [{'Url': '/images/photo123.jpg', 'Category': 'Survey'}],
      });
      expect(repair.progressStage, 1);
      expect(repair.nextAppointment?.type, 'Fitting');
      expect(repair.nextAppointment?.dateTime?.hour, 9);
      expect(repair.updates.single.isCurrent, isTrue);
      expect(repair.photos.single.url, '/images/photo123.jpg');
    });
    test('ticket parses enum values and unread indicator', () {
      final ticket = CustomerTicketListItem.fromJson({
        'Id': 17, 'Status': 1, 'HasUnreadMessages': true, 'MessageCount': 3,
      });
      expect(TicketStatus.label(ticket.status), 'Waiting for you');
      expect(ticket.hasUnreadMessages, isTrue);
      expect(ticket.messageCount, 3);
    });
  });
}
