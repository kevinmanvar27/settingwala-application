class GetpaymentstatusModel {
  bool success;
  GetpaymentstatusModelData data;

  GetpaymentstatusModel({
    required this.success,
    required this.data,
  });

  factory GetpaymentstatusModel.fromJson(Map<String, dynamic> json) {
    return GetpaymentstatusModel(
      success: json['success'] ?? false,
      data: GetpaymentstatusModelData.fromJson(json['data'] ?? {}),
    );
  }
}

class GetpaymentstatusModelData {
  bool hasSubscription;
  Subscription? subscription;

  GetpaymentstatusModelData({
    required this.hasSubscription,
    this.subscription,
  });

  factory GetpaymentstatusModelData.fromJson(Map<String, dynamic> json) {
    return GetpaymentstatusModelData(
      hasSubscription: json['has_subscription'] ?? false,
      subscription: json['subscription'] != null 
          ? Subscription.fromJson(json['subscription']) 
          : null,
    );
  }
}

class Subscription {
  dynamic id;
  String? planName;
  String? startDate;
  String? endDate;
  dynamic daysRemaining;
  String? status;

  Subscription({
    this.id,
    this.planName,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      planName: json['plan_name']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      daysRemaining: json['days_remaining'],
      status: json['status']?.toString(),
    );
  }
}
