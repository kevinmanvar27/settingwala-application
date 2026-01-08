class GetchatModel {
  bool success;
  GetchatModelData data;

  GetchatModel({
    required this.success,
    required this.data,
  });

  factory GetchatModel.fromJson(Map<String, dynamic> json) {
    return GetchatModel(
      success: json['success'] ?? false,
      data: GetchatModelData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class GetchatModelData {
  List<Chat> chats;

  GetchatModelData({
    required this.chats,
  });

  factory GetchatModelData.fromJson(Map<String, dynamic> json) {
    return GetchatModelData(
      chats: json['chats'] != null
          ? (json['chats'] as List).map((e) => Chat.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chats': chats.map((e) => e.toJson()).toList(),
    };
  }
}

class Chat {
  int bookingId;
  OtherUser otherUser;
  dynamic lastMessage;
  int unreadCount;
  String bookingStatus;
  DateTime bookingDate;
  String durationHours;
  DateTime updatedAt;

  Chat({
    required this.bookingId,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
    required this.bookingStatus,
    required this.bookingDate,
    required this.durationHours,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      bookingId: json['booking_id'] ?? 0,
      otherUser: OtherUser.fromJson(json['other_user'] ?? {}),
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'] ?? 0,
      bookingStatus: json['booking_status'] ?? '',
      bookingDate: DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      durationHours: json['duration_hours']?.toString() ?? '0',
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'other_user': otherUser.toJson(),
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'booking_status': bookingStatus,
      'booking_date': bookingDate.toIso8601String(),
      'duration_hours': durationHours,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OtherUser {
  int? id;
  String name;
  String avatar;

  OtherUser({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}
