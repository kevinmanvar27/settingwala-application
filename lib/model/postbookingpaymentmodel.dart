
import 'dart:convert';

PostBookingPaymentmodel postBookingPaymentmodelFromJson(String str) =>
    PostBookingPaymentmodel.fromJson(json.decode(str));

String postBookingPaymentmodelToJson(PostBookingPaymentmodel data) =>
    json.encode(data.toJson());

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class PostBookingPaymentmodel {
  bool success;
  String message;
  Data? data;

  PostBookingPaymentmodel({
    required this.success,
    required this.message,
    this.data,
  });

  factory PostBookingPaymentmodel.fromJson(Map<String, dynamic> json) =>
      PostBookingPaymentmodel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  Booking? booking;
  PaymentDetails? paymentDetails;

  Data({
    this.booking,
    this.paymentDetails,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        booking:
            json["booking"] != null ? Booking.fromJson(json["booking"]) : null,
        paymentDetails: json["payment_details"] != null
            ? PaymentDetails.fromJson(json["payment_details"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "booking": booking?.toJson(),
        "payment_details": paymentDetails?.toJson(),
      };
}

class Booking {
  int id;
  String? bookingDate;
  String? bookingDatetime;
  String? startTime;
  String? endTime;
  String? durationHours;
  double? actualDurationHours;
  String? hourlyRate;
  String? baseAmount;
  String? platformFee;
  String? totalAmount;
  String? commissionPercentage;
  String? commissionAmount;
  String? providerAmount;
  String? status;
  String? providerStatus;
  String? paymentStatus;
  String? paymentMethod;
  String? walletAmountUsed;
  String? cfAmountPaid;
  DateTime? paidAt;
  String? role;
  OtherUser? otherUser;
  String? providerServiceLocation;
  DateTime? createdAt;

  Booking({
    required this.id,
    this.bookingDate,
    this.bookingDatetime,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.actualDurationHours,
    this.hourlyRate,
    this.baseAmount,
    this.platformFee,
    this.totalAmount,
    this.commissionPercentage,
    this.commissionAmount,
    this.providerAmount,
    this.status,
    this.providerStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.walletAmountUsed,
    this.cfAmountPaid,
    this.paidAt,
    this.role,
    this.otherUser,
    this.providerServiceLocation,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"] ?? 0,
        bookingDate: json["booking_date"]?.toString(),
        bookingDatetime: json["booking_datetime"]?.toString(),
        startTime: json["start_time"]?.toString(),
        endTime: json["end_time"]?.toString(),
        durationHours: json["duration_hours"]?.toString(),
        actualDurationHours: _parseDouble(json["actual_duration_hours"]),
        hourlyRate: json["hourly_rate"]?.toString(),
        baseAmount: json["base_amount"]?.toString(),
        platformFee: json["platform_fee"]?.toString(),
        totalAmount: json["total_amount"]?.toString(),
        commissionPercentage: json["commission_percentage"]?.toString(),
        commissionAmount: json["commission_amount"]?.toString(),
        providerAmount: json["provider_amount"]?.toString(),
        status: json["status"]?.toString(),
        providerStatus: json["provider_status"]?.toString(),
        paymentStatus: json["payment_status"]?.toString(),
        paymentMethod: json["payment_method"]?.toString(),
        walletAmountUsed: json["wallet_amount_used"]?.toString(),
        cfAmountPaid: json["cf_amount_paid"]?.toString(),
        paidAt: json["paid_at"] != null
            ? DateTime.tryParse(json["paid_at"].toString())
            : null,
        role: json["role"]?.toString(),
        otherUser: json["other_user"] != null
            ? OtherUser.fromJson(json["other_user"])
            : null,
        providerServiceLocation: json["provider_service_location"]?.toString(),
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_date": bookingDate,
        "booking_datetime": bookingDatetime,
        "start_time": startTime,
        "end_time": endTime,
        "duration_hours": durationHours,
        "actual_duration_hours": actualDurationHours,
        "hourly_rate": hourlyRate,
        "base_amount": baseAmount,
        "platform_fee": platformFee,
        "total_amount": totalAmount,
        "commission_percentage": commissionPercentage,
        "commission_amount": commissionAmount,
        "provider_amount": providerAmount,
        "status": status,
        "provider_status": providerStatus,
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "wallet_amount_used": walletAmountUsed,
        "cf_amount_paid": cfAmountPaid,
        "paid_at": paidAt?.toIso8601String(),
        "role": role,
        "other_user": otherUser?.toJson(),
        "provider_service_location": providerServiceLocation,
        "created_at": createdAt?.toIso8601String(),
      };
}

class OtherUser {
  int id;
  String? name;
  String? profilePicture;
  String? hourlyRate;
  String? serviceLocation;

  OtherUser({
    required this.id,
    this.name,
    this.profilePicture,
    this.hourlyRate,
    this.serviceLocation,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) => OtherUser(
        id: json["id"] ?? 0,
        name: json["name"]?.toString(),
        profilePicture: json["profile_picture"]?.toString(),
        hourlyRate: json["hourly_rate"]?.toString(),
        serviceLocation: json["service_location"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profile_picture": profilePicture,
        "hourly_rate": hourlyRate,
        "service_location": serviceLocation,
      };
}

class PaymentDetails {
  int? totalAmount;
  int? walletUsed;
  int? cashfreePaid;
  String? paymentMethod;

  PaymentDetails({
    this.totalAmount,
    this.walletUsed,
    this.cashfreePaid,
    this.paymentMethod,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
        totalAmount: json["total_amount"] is int
            ? json["total_amount"]
            : int.tryParse(json["total_amount"]?.toString() ?? "0"),
        walletUsed: json["wallet_used"] is int
            ? json["wallet_used"]
            : int.tryParse(json["wallet_used"]?.toString() ?? "0"),
        cashfreePaid: json["cashfree_paid"] is int
            ? json["cashfree_paid"]
            : int.tryParse(json["cashfree_paid"]?.toString() ?? "0"),
        paymentMethod: json["payment_method"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "total_amount": totalAmount,
        "wallet_used": walletUsed,
        "cashfree_paid": cashfreePaid,
        "payment_method": paymentMethod,
      };
}
