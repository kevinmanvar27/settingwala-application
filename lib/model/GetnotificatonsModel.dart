class GetnotificationsModel {
  bool success;
  GetnotificationsModelData data;

  GetnotificationsModel({
    required this.success,
    required this.data,
  });
}

class GetnotificationsModelData {
  List<NotificationItem> notifications;
  Pagination pagination;

  GetnotificationsModelData({
    required this.notifications,
    required this.pagination,
  });
}

class NotificationItem {
  int id;
  String type;
  String title;
  String message;
  NotificationData data;
  DateTime readAt;
  DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });
}

class NotificationData {
  int bookingId;
  int clientId;
  int providerId;
  String amount;
  String durationHours;
  DateTime date;
  String meetingLocation;
  String notes;
  String? providerName;
  String? paymentStatus;
  String? startTime;
  String? endTime;
  String? status;
  String? providerStatus;

  NotificationData({
    required this.bookingId,
    required this.clientId,
    required this.providerId,
    required this.amount,
    required this.durationHours,
    required this.date,
    required this.meetingLocation,
    required this.notes,
    this.providerName,
    this.paymentStatus,
    this.startTime,
    this.endTime,
    this.status,
    this.providerStatus,
  });

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

}
