class BlockedUsersModel {
  final bool success;
  final String message;
  final List<BlockedUser> data;

  BlockedUsersModel({
  required this.success,
  required this.message,
  required this.data,
  });

  factory BlockedUsersModel.fromJson(Map<String, dynamic> json) {
  final blockedUsersList = json['data']?['blocked_users'] ?? json['data'] ?? [];
  return BlockedUsersModel(
  success: json['success'] ?? false,
  message: json['message'] ?? '',
  data: blockedUsersList is List
  ? blockedUsersList.map((e) => BlockedUser.fromJson(e)).toList()
      : [],
  );
  }
  }

  class BlockedUser {
  final int id;
  final int blockedUserId;
  final String name;
  final String? email;
  final String? profilePicture;
  final String? reason;
  final String blockedOn;
  final String timeAgo;

  BlockedUser({
  required this.id,
  required this.blockedUserId,
  required this.name,
  this.email,
  this.profilePicture,
  this.reason,
  required this.blockedOn,
  required this.timeAgo,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
  String blockedOn = '';
  String timeAgo = '';
  if (json['blocked_at'] != null) {
  try {
  final blockedAt = DateTime.parse(json['blocked_at'].toString());
  blockedOn = '${blockedAt.day}/${blockedAt.month}/${blockedAt.year}';
  final diff = DateTime.now().difference(blockedAt);
  if (diff.inDays > 0) {
  timeAgo = '${diff.inDays} days ago';
  } else if (diff.inHours > 0) {
  timeAgo = '${diff.inHours} hours ago';
  } else {
  timeAgo = '${diff.inMinutes} minutes ago';
  }
  } catch (e) {
  blockedOn = json['blocked_at']?.toString() ?? '';
  }
  }

  return BlockedUser(
  id: json['id'] ?? 0,
  blockedUserId: json['id'] ?? json['blocked_user_id'] ?? json['blockedUserId'] ?? 0,
  name: json['name'] ?? 'Unknown',
  email: json['email'],
  profilePicture: json['avatar'] ?? json['profile_picture'] ?? json['profilePicture'],
  reason: json['reason'],
  blockedOn: json['blocked_on'] ?? json['blockedOn'] ?? blockedOn,
  timeAgo: json['time_ago'] ?? json['timeAgo'] ?? timeAgo,
  );
  }
  }
