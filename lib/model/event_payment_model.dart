import 'dart:convert';

EventPaymentOrderModel eventPaymentOrderModelFromJson(String str) =>
    EventPaymentOrderModel.fromJson(json.decode(str));

String eventPaymentOrderModelToJson(EventPaymentOrderModel data) =>
    json.encode(data.toJson());

class EventPaymentOrderModel {
  bool success;
  String? message;
  EventPaymentOrderData? data;

  EventPaymentOrderModel({
    required this.success,
    this.message,
    this.data,
  });

  factory EventPaymentOrderModel.fromJson(Map<String, dynamic> json) =>
      EventPaymentOrderModel(
        success: json["success"] ?? false,
        message: json["message"],
        data: json["data"] != null
            ? EventPaymentOrderData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

/// Model matching Laravel API response format:
/// {
///   "payment_session_id": "session_xxx",
///   "order_id": "order_xxx",
///   "amount": 500.00,
///   "currency": "INR",
///   "event_payment_id": 123,
///   "environment": "sandbox"
/// }
class EventPaymentOrderData {
  int eventPaymentId;
  double amount;
  String currency;
  String orderId;
  String paymentSessionId;
  String environment;

  EventPaymentOrderData({
    required this.eventPaymentId,
    required this.amount,
    required this.currency,
    required this.orderId,
    required this.paymentSessionId,
    required this.environment,
  });

  factory EventPaymentOrderData.fromJson(Map<String, dynamic> json) =>
      EventPaymentOrderData(
        eventPaymentId: json["event_payment_id"] ?? 0,
        amount: _parseDouble(json["amount"]) ?? 0.0,
        currency: json["currency"] ?? 'INR',
        orderId: json["order_id"] ?? '',
        paymentSessionId: json["payment_session_id"] ?? '',
        environment: json["environment"] ?? 'sandbox',
      );

  Map<String, dynamic> toJson() => {
        "event_payment_id": eventPaymentId,
        "amount": amount,
        "currency": currency,
        "order_id": orderId,
        "payment_session_id": paymentSessionId,
        "environment": environment,
      };

  /// Helper to check if environment is production
  bool get isProduction => environment.toLowerCase() == 'production';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// Verify Payment Response Model
class EventPaymentVerifyModel {
  bool success;
  String? message;
  EventPaymentVerifyData? data;

  EventPaymentVerifyModel({
    required this.success,
    this.message,
    this.data,
  });

  factory EventPaymentVerifyModel.fromJson(Map<String, dynamic> json) =>
      EventPaymentVerifyModel(
        success: json["success"] ?? false,
        message: json["message"],
        data: json["data"] != null
            ? EventPaymentVerifyData.fromJson(json["data"])
            : null,
      );
}

/// Laravel verify payment response:
/// {
///   "status": "completed",
///   "event_payment_id": 123,
///   "amount_paid": 500.00,
///   "transaction_id": "cf_xxx"
/// }
class EventPaymentVerifyData {
  String status;
  int? eventPaymentId;
  double? amountPaid;
  String? transactionId;

  EventPaymentVerifyData({
    required this.status,
    this.eventPaymentId,
    this.amountPaid,
    this.transactionId,
  });

  factory EventPaymentVerifyData.fromJson(Map<String, dynamic> json) =>
      EventPaymentVerifyData(
        status: json["status"] ?? 'pending',
        eventPaymentId: json["event_payment_id"],
        amountPaid: _parseDouble(json["amount_paid"]),
        transactionId: json["transaction_id"],
      );

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
