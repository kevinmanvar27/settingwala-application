
import 'dart:convert';

BookingPaymentDetailsModel bookingPaymentDetailsModelFromJson(String str) =>
    BookingPaymentDetailsModel.fromJson(json.decode(str));

String bookingPaymentDetailsModelToJson(BookingPaymentDetailsModel data) =>
    json.encode(data.toJson());

class BookingPaymentDetailsModel {
  final bool success;
  final String? message;
  final BookingPaymentDetails? data;

  BookingPaymentDetailsModel({
    required this.success,
    this.message,
    this.data,
  });

  factory BookingPaymentDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingPaymentDetailsModel(
        success: json["success"] ?? false,
        message: json["message"],
        data: json["data"] != null
            ? BookingPaymentDetails.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class BookingPaymentDetails {
  final int? bookingId;
  final String? bookingStatus;
  final String? paymentStatus;
  
  final double? totalAmount;
  final double? hourlyRate;
  final double? durationHours;
  final double? baseAmount;
  final double? platformFee;
  final double? walletBalance;
  final double? walletUsage;
  final double? cashfreeAmount;
  final bool? paymentRequired;
  
  final PaymentUserDetails? provider;
  
  final CashfreeOrderDetails? cashfreeOrder;
  final String? cashfreeKey;
  final String? cashfreeEnv;
  
  final double? walletAmountUsed;
  final double? cashfreeAmountPaid;
  final double? gst;
  final double? netAmount;
  final String? scheduledDate;
  final int? durationMinutes;
  final PaymentUserDetails? bookedWith;
  final PaymentTransactionDetails? paymentDetails;
  final String? createdAt;
  final String? updatedAt;
  final String? paidAt;

  BookingPaymentDetails({
    this.bookingId,
    this.bookingStatus,
    this.paymentStatus,
    this.totalAmount,
    this.hourlyRate,
    this.durationHours,
    this.baseAmount,
    this.platformFee,
    this.walletBalance,
    this.walletUsage,
    this.cashfreeAmount,
    this.paymentRequired,
    this.provider,
    this.cashfreeOrder,
    this.cashfreeKey,
    this.cashfreeEnv,
    this.walletAmountUsed,
    this.cashfreeAmountPaid,
    this.gst,
    this.netAmount,
    this.scheduledDate,
    this.durationMinutes,
    this.bookedWith,
    this.paymentDetails,
    this.createdAt,
    this.updatedAt,
    this.paidAt,
  });

  factory BookingPaymentDetails.fromJson(Map<String, dynamic> json) =>
      BookingPaymentDetails(
        bookingId: json["booking_id"] ?? json["id"],
        bookingStatus: json["booking_status"] ?? json["status"],
        paymentStatus: json["payment_status"],
        totalAmount: _parseDouble(json["total_amount"]),
        hourlyRate: _parseDouble(json["hourly_rate"]),
        durationHours: _parseDouble(json["duration_hours"]),
        baseAmount: _parseDouble(json["base_amount"]),
        platformFee: _parseDouble(json["platform_fee"]),
        walletBalance: _parseDouble(json["wallet_balance"]),
        walletUsage: _parseDouble(json["wallet_usage"]),
        cashfreeAmount: _parseDouble(json["cashfree_amount"]),
        paymentRequired: json["payment_required"],
        provider: json["provider"] != null
            ? PaymentUserDetails.fromJson(json["provider"])
            : null,
        cashfreeOrder: json["cashfree_order"] != null
            ? CashfreeOrderDetails.fromJson(json["cashfree_order"])
            : null,
        cashfreeKey: json["cashfree_key"],
        cashfreeEnv: json["cashfree_env"],
        walletAmountUsed: _parseDouble(json["wallet_amount_used"]) ?? _parseDouble(json["wallet_usage"]),
        cashfreeAmountPaid: _parseDouble(json["cashfree_amount_paid"]) ?? _parseDouble(json["cashfree_amount"]),
        gst: _parseDouble(json["gst"]),
        netAmount: _parseDouble(json["net_amount"]),
        scheduledDate: json["scheduled_date"] ?? json["date"],
        durationMinutes: json["duration_minutes"] ?? json["duration"],
        bookedWith: json["booked_with"] != null
            ? PaymentUserDetails.fromJson(json["booked_with"])
            : json["provider"] != null
                ? PaymentUserDetails.fromJson(json["provider"])
                : null,
        paymentDetails: json["payment_details"] != null
            ? PaymentTransactionDetails.fromJson(json["payment_details"])
            : null,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        paidAt: json["paid_at"],
      );

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "booking_status": bookingStatus,
        "payment_status": paymentStatus,
        "total_amount": totalAmount,
        "hourly_rate": hourlyRate,
        "duration_hours": durationHours,
        "base_amount": baseAmount,
        "platform_fee": platformFee,
        "wallet_balance": walletBalance,
        "wallet_usage": walletUsage,
        "cashfree_amount": cashfreeAmount,
        "payment_required": paymentRequired,
        "provider": provider?.toJson(),
        "cashfree_order": cashfreeOrder?.toJson(),
        "cashfree_key": cashfreeKey,
        "cashfree_env": cashfreeEnv,
      };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class PaymentUserDetails {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final String? gender;
  final double? hourlyRate;

  PaymentUserDetails({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.gender,
    this.hourlyRate,
  });

  factory PaymentUserDetails.fromJson(Map<String, dynamic> json) =>
      PaymentUserDetails(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"] ?? json["mobile"],
        image: json["image"] ?? json["profile_image"] ?? json["avatar"],
        gender: json["gender"],
        hourlyRate: BookingPaymentDetails._parseDouble(json["hourly_rate"] ?? json["price"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "image": image,
        "gender": gender,
        "hourly_rate": hourlyRate,
      };
}

class CashfreeOrderDetails {
  final String? orderId;
  final String? cfOrderId;
  final String? paymentSessionId;
  final String? orderStatus;
  final double? orderAmount;
  final String? orderCurrency;

  CashfreeOrderDetails({
    this.orderId,
    this.cfOrderId,
    this.paymentSessionId,
    this.orderStatus,
    this.orderAmount,
    this.orderCurrency,
  });

  factory CashfreeOrderDetails.fromJson(Map<String, dynamic> json) =>
      CashfreeOrderDetails(
        orderId: json["order_id"]?.toString(),
        cfOrderId: json["cf_order_id"]?.toString(),
        paymentSessionId: json["payment_session_id"],
        orderStatus: json["order_status"],
        orderAmount: BookingPaymentDetails._parseDouble(json["order_amount"]),
        orderCurrency: json["order_currency"] ?? "INR",
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "cf_order_id": cfOrderId,
        "payment_session_id": paymentSessionId,
        "order_status": orderStatus,
        "order_amount": orderAmount,
        "order_currency": orderCurrency,
      };
}

class PaymentTransactionDetails {
  final String? transactionId;
  final String? cfOrderId;
  final String? cfTransactionId;
  final String? orderId;
  final String? paymentMethod;
  final String? paymentMode;
  final String? paymentStatus;
  final double? amount;
  final String? currency;
  final String? bankReference;
  final String? paymentTime;
  final String? paymentMessage;

  PaymentTransactionDetails({
    this.transactionId,
    this.cfOrderId,
    this.cfTransactionId,
    this.orderId,
    this.paymentMethod,
    this.paymentMode,
    this.paymentStatus,
    this.amount,
    this.currency,
    this.bankReference,
    this.paymentTime,
    this.paymentMessage,
  });

  factory PaymentTransactionDetails.fromJson(Map<String, dynamic> json) =>
      PaymentTransactionDetails(
        transactionId: json["transaction_id"]?.toString(),
        cfOrderId: json["cf_order_id"]?.toString(),
        cfTransactionId: json["cf_transaction_id"]?.toString(),
        orderId: json["order_id"],
        paymentMethod: json["payment_method"],
        paymentMode: json["payment_mode"],
        paymentStatus: json["payment_status"] ?? json["status"],
        amount: BookingPaymentDetails._parseDouble(json["amount"]),
        currency: json["currency"] ?? "INR",
        bankReference: json["bank_reference"],
        paymentTime: json["payment_time"] ?? json["paid_at"],
        paymentMessage: json["payment_message"] ?? json["message"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "cf_order_id": cfOrderId,
        "cf_transaction_id": cfTransactionId,
        "order_id": orderId,
        "payment_method": paymentMethod,
        "payment_mode": paymentMode,
        "payment_status": paymentStatus,
        "amount": amount,
        "currency": currency,
        "bank_reference": bankReference,
        "payment_time": paymentTime,
        "payment_message": paymentMessage,
      };
}
