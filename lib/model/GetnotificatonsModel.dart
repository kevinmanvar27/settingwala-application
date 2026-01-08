class GetnotificationsModel {
  bool success;
  GetnotificationsModelData data;

  GetnotificationsModel({
    required this.success,
    required this.data,
  });

  factory GetnotificationsModel.fromJson(Map<String, dynamic> json) {
    return GetnotificationsModel(
      success: json['success'] ?? false,
      data: GetnotificationsModelData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class GetnotificationsModelData {
  List<NotificationItem> notifications;
  Pagination pagination;

  GetnotificationsModelData({
    required this.notifications,
    required this.pagination,
  });

  factory GetnotificationsModelData.fromJson(Map<String, dynamic> json) {
    return GetnotificationsModelData(
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => NotificationItem.fromJson(e))
              .toList()
          : [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class NotificationItem {
  int id;
  String type;
  String title;
  String message;
  NotificationData? data;
  DateTime? readAt;
  DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data?.toJson(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class NotificationData {
  int? bookingId;
  int? clientId;
  int? providerId;
  String? amount;
  String? durationHours;
  DateTime? date;
  String? meetingLocation;
  String? notes;
  String? providerName;
  String? paymentStatus;
  String? startTime;
  String? endTime;
  String? status;
  String? providerStatus;

  NotificationData({
    this.bookingId,
    this.clientId,
    this.providerId,
    this.amount,
    this.durationHours,
    this.date,
    this.meetingLocation,
    this.notes,
    this.providerName,
    this.paymentStatus,
    this.startTime,
    this.endTime,
    this.status,
    this.providerStatus,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      bookingId: json['booking_id'],
      clientId: json['client_id'],
      providerId: json['provider_id'],
      amount: json['amount']?.toString(),
      durationHours: json['duration_hours']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
      providerName: json['provider_name'],
      paymentStatus: json['payment_status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      providerStatus: json['provider_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'client_id': clientId,
      'provider_id': providerId,
      'amount': amount,
      'duration_hours': durationHours,
      'date': date?.toIso8601String(),
      'meeting_location': meetingLocation,
      'notes': notes,
      'provider_name': providerName,
      'payment_status': paymentStatus,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'provider_status': providerStatus,
    };
  }
}

class Pagination {
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}
