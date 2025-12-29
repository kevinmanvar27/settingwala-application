// Booking Payment Model - For Cashfree Payment Integration
// Similar to PostpurchaseModel for subscriptions

import 'dart:convert';

BookingPaymentModel bookingPaymentModelFromJson(String str) => 
    BookingPaymentModel.fromJson(json.decode(str));

String bookingPaymentModelToJson(BookingPaymentModel data) => 
    json.encode(data.toJson());

class BookingPaymentModel {
  bool success;
  String? message;
  BookingPaymentData? data;

  BookingPaymentModel({
    required this.success,
    this.message,
    this.data,
  });

  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) => BookingPaymentModel(
    success: json["success"] ?? false,
    message: json["message"],
    data: json["data"] != null ? BookingPaymentData.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class BookingPaymentData {
  bool paymentCompleted;
  int bookingId;
  String amount;
  BookingCashfreeOrder cashfreeOrder;
  String cashfreeKey;
  String cashfreeEnv;

  BookingPaymentData({
    required this.paymentCompleted,
    required this.bookingId,
    required this.amount,
    required this.cashfreeOrder,
    required this.cashfreeKey,
    required this.cashfreeEnv,
  });

  factory BookingPaymentData.fromJson(Map<String, dynamic> json) => BookingPaymentData(
    paymentCompleted: json["payment_completed"] ?? false,
    bookingId: json["booking_id"] ?? 0,
    amount: json["amount"]?.toString() ?? "0",
    cashfreeOrder: BookingCashfreeOrder.fromJson(json["cashfree_order"] ?? {}),
    cashfreeKey: json["cashfree_key"] ?? "",
    cashfreeEnv: json["cashfree_env"] ?? "SANDBOX",
  );

  Map<String, dynamic> toJson() => {
    "payment_completed": paymentCompleted,
    "booking_id": bookingId,
    "amount": amount,
    "cashfree_order": cashfreeOrder.toJson(),
    "cashfree_key": cashfreeKey,
    "cashfree_env": cashfreeEnv,
  };
}

class BookingCashfreeOrder {
  String orderId;
  String cfOrderId;
  String paymentSessionId;
  String orderStatus;

  BookingCashfreeOrder({
    required this.orderId,
    required this.cfOrderId,
    required this.paymentSessionId,
    required this.orderStatus,
  });

  factory BookingCashfreeOrder.fromJson(Map<String, dynamic> json) => BookingCashfreeOrder(
    orderId: json["order_id"] ?? "",
    cfOrderId: json["cf_order_id"]?.toString() ?? "",
    paymentSessionId: json["payment_session_id"] ?? "",
    orderStatus: json["order_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "cf_order_id": cfOrderId,
    "payment_session_id": paymentSessionId,
    "order_status": orderStatus,
  };
}

// Response model for verify booking payment
class VerifyBookingPaymentResponse {
  final bool success;
  final String? message;
  final BookingPaymentStatus? booking;

  VerifyBookingPaymentResponse({
    required this.success,
    this.message,
    this.booking,
  });

  factory VerifyBookingPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyBookingPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'],
      booking: json['data']?['booking'] != null
          ? BookingPaymentStatus.fromJson(json['data']['booking'])
          : null,
    );
  }
}

class BookingPaymentStatus {
  final int id;
  final String status;
  final String? paymentStatus;

  BookingPaymentStatus({
    required this.id,
    required this.status,
    this.paymentStatus,
  });

  factory BookingPaymentStatus.fromJson(Map<String, dynamic> json) {
    return BookingPaymentStatus(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'],
    );
  }
}
