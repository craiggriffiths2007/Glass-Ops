/// .NET System.Text.Json ordinarily returns camelCase names; tolerate PascalCase
/// too, so the UI also works if the backend changes its naming policy.
Object? jsonField(Map<String, dynamic> json, String field) {
  if (json.containsKey(field)) return json[field];
  final needle = field.toLowerCase();
  for (final entry in json.entries) {
    if (entry.key.toLowerCase() == needle) return entry.value;
  }
  return null;
}

String jsonString(Map<String, dynamic> json, String key) =>
    jsonField(json, key)?.toString() ?? '';

int jsonInt(Map<String, dynamic> json, String key) {
  final value = jsonField(json, key);
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool jsonBool(Map<String, dynamic> json, String key) {
  final value = jsonField(json, key);
  return value == true || value?.toString().toLowerCase() == 'true';
}

DateTime? jsonDate(Map<String, dynamic> json, String key) {
  final value = jsonField(json, key);
  return value == null ? null : DateTime.tryParse(value.toString());
}

Map<String, dynamic>? jsonObject(Map<String, dynamic> json, String key) {
  final value = jsonField(json, key);
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

List<T> jsonArray<T>(Map<String, dynamic> json, String key,
    T Function(Map<String, dynamic>) decode) {
  final value = jsonField(json, key);
  if (value is! List) return [];
  return value.whereType<Map>().map((e) => decode(Map<String, dynamic>.from(e))).toList();
}

class CustomerLoginResult {
  CustomerLoginResult({
    required this.authenticationString,
    required this.customerId,
    required this.contractId,
    required this.customerName,
  });
  final String authenticationString;
  final int customerId;
  final int contractId;
  final String customerName;
  factory CustomerLoginResult.fromJson(Map<String, dynamic> json) =>
      CustomerLoginResult(
        authenticationString: jsonString(json, 'authenticationString'),
        customerId: jsonInt(json, 'customerId'),
        contractId: jsonInt(json, 'contractId'),
        customerName: jsonString(json, 'customerName'),
      );
}

/// Keep the numeric values used by the existing Glass Ops ASP.NET API.
class ContractStatus {
  static const reported = 0;
  static const surveyBooked = 1;
  static const surveyCompleted = 2;
  static const fittingBooked = 3;
  static const fittingCompleted = 4;
  static const cancelled = 5;

  static int fromJson(Object? value) {
    if (value is num) return value.toInt();
    const values = <String, int>{
      'reported': reported,
      'surveybooked': surveyBooked,
      'surveycompleted': surveyCompleted,
      'fittingbooked': fittingBooked,
      'fittingcompleted': fittingCompleted,
      'cancelled': cancelled,
    };
    return values[value?.toString().toLowerCase().replaceAll('_', '')] ??
        int.tryParse(value?.toString() ?? '') ?? reported;
  }
}

class CustomerRepair {
  CustomerRepair({
    required this.contractId,
    required this.reference,
    required this.customerName,
    required this.addressLine1,
    required this.town,
    required this.postcode,
    required this.damageDescription,
    required this.causeOfDamage,
    required this.status,
    required this.statusTitle,
    required this.statusDescription,
    required this.statusEta,
    required this.nextAppointment,
    required this.items,
    required this.updates,
    required this.photos,
  });
  final int contractId;
  final String reference;
  final String customerName;
  final String addressLine1;
  final String town;
  final String postcode;
  final String damageDescription;
  final String causeOfDamage;
  final int status;
  final String statusTitle;
  final String statusDescription;
  final String statusEta;
  final CustomerAppointment? nextAppointment;
  final List<CustomerRepairItem> items;
  final List<CustomerRepairUpdate> updates;
  final List<CustomerPhoto> photos;

  factory CustomerRepair.fromJson(Map<String, dynamic> json) => CustomerRepair(
        contractId: jsonInt(json, 'contractId'),
        reference: jsonString(json, 'reference'),
        customerName: jsonString(json, 'customerName'),
        addressLine1: jsonString(json, 'addressLine1'),
        town: jsonString(json, 'town'),
        postcode: jsonString(json, 'postcode'),
        damageDescription: jsonString(json, 'damageDescription'),
        causeOfDamage: jsonString(json, 'causeOfDamage'),
        status: ContractStatus.fromJson(jsonField(json, 'status')),
        statusTitle: jsonString(json, 'statusTitle'),
        statusDescription: jsonString(json, 'statusDescription'),
        statusEta: jsonString(json, 'statusEta'),
        nextAppointment: jsonObject(json, 'nextAppointment') == null
            ? null
            : CustomerAppointment.fromJson(
                jsonObject(json, 'nextAppointment')!),
        items: jsonArray(json, 'items', CustomerRepairItem.fromJson),
        updates: jsonArray(json, 'updates', CustomerRepairUpdate.fromJson),
        photos: jsonArray(json, 'photos', CustomerPhoto.fromJson),
      );

  int get progressStage => switch (status) {
        ContractStatus.surveyBooked || ContractStatus.surveyCompleted => 1,
        ContractStatus.fittingBooked => 2,
        ContractStatus.fittingCompleted => 3,
        _ => 0,
      };
}

class CustomerAppointment {
  CustomerAppointment({
    required this.type,
    required this.dateTime,
    required this.engineerName,
    required this.notes,
  });
  final String type;
  final DateTime? dateTime;
  final String engineerName;
  final String notes;
  factory CustomerAppointment.fromJson(Map<String, dynamic> json) =>
      CustomerAppointment(
        type: jsonString(json, 'type'),
        dateTime: jsonDate(json, 'dateTime'),
        engineerName: jsonString(json, 'engineerName'),
        notes: jsonString(json, 'notes'),
      );
}

class CustomerRepairItem {
  CustomerRepairItem({
    required this.title,
    required this.description,
    required this.location,
  });
  final String title;
  final String description;
  final String location;
  factory CustomerRepairItem.fromJson(Map<String, dynamic> json) =>
      CustomerRepairItem(
        title: jsonString(json, 'title'),
        description: jsonString(json, 'description'),
        location: jsonString(json, 'location'),
      );
}

class CustomerRepairUpdate {
  CustomerRepairUpdate({
    required this.dateTime,
    required this.title,
    required this.description,
    required this.isCurrent,
  });
  final DateTime? dateTime;
  final String title;
  final String description;
  final bool isCurrent;
  factory CustomerRepairUpdate.fromJson(Map<String, dynamic> json) =>
      CustomerRepairUpdate(
        dateTime: jsonDate(json, 'dateTime'),
        title: jsonString(json, 'title'),
        description: jsonString(json, 'description'),
        isCurrent: jsonBool(json, 'isCurrent'),
      );
}

class CustomerPhoto {
  CustomerPhoto({
    required this.url,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
  });
  final String url;
  final String title;
  final String description;
  final String category;
  final DateTime? dateTime;
  factory CustomerPhoto.fromJson(Map<String, dynamic> json) => CustomerPhoto(
        url: jsonString(json, 'url'),
        title: jsonString(json, 'title'),
        description: jsonString(json, 'description'),
        category: jsonString(json, 'category'),
        dateTime: jsonDate(json, 'dateTime'),
      );
}

class CustomerAccount {
  CustomerAccount({
    required this.name,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.town,
    required this.postcode,
    required this.phone,
  });
  final String name;
  final String email;
  final String addressLine1;
  final String addressLine2;
  final String town;
  final String postcode;
  final String phone;
  factory CustomerAccount.fromJson(Map<String, dynamic> json) => CustomerAccount(
        name: jsonString(json, 'name'),
        email: jsonString(json, 'email'),
        addressLine1: jsonString(json, 'addressLine1'),
        addressLine2: jsonString(json, 'addressLine2'),
        town: jsonString(json, 'town'),
        postcode: jsonString(json, 'postcode'),
        phone: jsonString(json, 'phone'),
      );
}

class TicketStatus {
  static const open = 0;
  static const awaitingCustomer = 1;
  static const awaitingOffice = 2;
  static const closed = 3;
  static int parse(Object? input) {
    if (input is num) return input.toInt();
    return switch (input?.toString().toLowerCase()) {
      'awaitingcustomer' => awaitingCustomer,
      'awaitingoffice' => awaitingOffice,
      'closed' => closed,
      _ => int.tryParse(input?.toString() ?? '') ?? open,
    };
  }
  static String label(int status) => switch (status) {
        awaitingCustomer => 'Waiting for you',
        awaitingOffice => 'Waiting for Glass Ops',
        closed => 'Closed',
        _ => 'Open',
      };
}

class CustomerTicketListItem {
  CustomerTicketListItem({
    required this.id,
    required this.subject,
    required this.status,
    required this.created,
    required this.lastMessageDate,
    required this.messageCount,
    required this.hasUnreadMessages,
  });
  final int id;
  final String subject;
  final int status;
  final DateTime? created;
  final DateTime? lastMessageDate;
  final int messageCount;
  final bool hasUnreadMessages;
  factory CustomerTicketListItem.fromJson(Map<String, dynamic> json) =>
      CustomerTicketListItem(
        id: jsonInt(json, 'id'),
        subject: jsonString(json, 'subject'),
        status: TicketStatus.parse(jsonField(json, 'status')),
        created: jsonDate(json, 'created'),
        lastMessageDate: jsonDate(json, 'lastMessageDate'),
        messageCount: jsonInt(json, 'messageCount'),
        hasUnreadMessages: jsonBool(json, 'hasUnreadMessages'),
      );
}

class CustomerTicket {
  CustomerTicket({
    required this.id,
    required this.contractId,
    required this.subject,
    required this.status,
    required this.created,
    required this.messages,
  });
  final int id;
  final int contractId;
  final String subject;
  final int status;
  final DateTime? created;
  final List<CustomerTicketMessage> messages;
  factory CustomerTicket.fromJson(Map<String, dynamic> json) => CustomerTicket(
        id: jsonInt(json, 'id'),
        contractId: jsonInt(json, 'contractId'),
        subject: jsonString(json, 'subject'),
        status: TicketStatus.parse(jsonField(json, 'status')),
        created: jsonDate(json, 'created'),
        messages: jsonArray(json, 'messages', CustomerTicketMessage.fromJson),
      );
}

class CustomerTicketMessage {
  CustomerTicketMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderName,
    required this.created,
  });
  final int id;
  final String message;
  final int sender;
  final String senderName;
  final DateTime? created;
  factory CustomerTicketMessage.fromJson(Map<String, dynamic> json) =>
      CustomerTicketMessage(
        id: jsonInt(json, 'id'),
        message: jsonString(json, 'message'),
        sender: switch (jsonField(json, 'sender')?.toString().toLowerCase()) {
          'customer' => 0,
          'headoffice' => 1,
          _ => jsonInt(json, 'sender'),
        },
        senderName: jsonString(json, 'senderName'),
        created: jsonDate(json, 'created'),
      );
}
