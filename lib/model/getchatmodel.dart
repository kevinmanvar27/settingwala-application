class GetchatModel {
  bool success;
  GetchatModelData data;

  GetchatModel({
    required this.success,
    required this.data,
  });
}

class GetchatModelData {
  List<Chat> chats;

  GetchatModelData({
    required this.chats,
  });

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

}