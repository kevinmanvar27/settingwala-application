class Getusersmodel {
  bool success;
  Data data;

  Getusersmodel({
    required this.success,
    required this.data,
  });

  factory Getusersmodel.fromJson(Map<String, dynamic> json) => Getusersmodel(
    success: json["success"] ?? false,
    data: Data.fromJson(json["data"]),
  );
}

class Data {
  List<User> users;
  Pagination pagination;

  Data({
    required this.users,
    required this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );
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

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"] ?? 0,
    lastPage: json["last_page"] ?? 0,
    perPage: json["per_page"] ?? 0,
    total: json["total"] ?? 0,
  );
}

class User {
  int id;
  String name;
  String profilePicture;
  double? age;
  dynamic city;
  dynamic state;
  dynamic bio;
  String? gender;
  dynamic height;
  dynamic bodyType;
  dynamic education;
  dynamic occupation;
  dynamic relationshipStatus;
  dynamic smoking;
  dynamic drinking;
  dynamic languages;
  dynamic interests;
  bool isTimeSpendingEnabled;
  dynamic hourlyRate;
  dynamic timeSpendingServices;
  dynamic timeSpendingDescription;
  bool isVerified;
  bool isOnline;
  dynamic lastSeen;
  int galleryCount;
  String? firstGalleryImage;
  dynamic rating;
  dynamic reviewsCount;

  User({
    required this.id,
    required this.name,
    required this.profilePicture,
    this.age,
    this.city,
    this.state,
    this.bio,
    this.gender,
    this.height,
    this.bodyType,
    this.education,
    this.occupation,
    this.relationshipStatus,
    this.smoking,
    this.drinking,
    this.languages,
    this.interests,
    required this.isTimeSpendingEnabled,
    this.hourlyRate,
    this.timeSpendingServices,
    this.timeSpendingDescription,
    required this.isVerified,
    required this.isOnline,
    this.lastSeen,
    required this.galleryCount,
    this.firstGalleryImage,
    this.rating,
    this.reviewsCount,
  });

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return defaultValue;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    profilePicture: json["profile_picture"] ?? '',
    age: json["age"]?.toDouble(),
    city: json["city"],
    state: json["state"],
    bio: json["bio"],
    gender: json["gender"],
    height: json["height"],
    bodyType: json["body_type"],
    education: json["education"],
    occupation: json["occupation"],
    relationshipStatus: json["relationship_status"],
    smoking: json["smoking"],
    drinking: json["drinking"],
    languages: json["languages"],
    interests: json["interests"],
    isTimeSpendingEnabled: _parseBool(json["is_time_spending_enabled"]),
    hourlyRate: json["hourly_rate"],
    timeSpendingServices: json["time_spending_services"],
    timeSpendingDescription: json["time_spending_description"],
    isVerified: _parseBool(json["is_verified"]),
    isOnline: _parseBool(json["is_online"]),
    lastSeen: json["last_seen"],
    galleryCount: json["gallery_count"] ?? 0,
    firstGalleryImage: json["first_gallery_image"],
    rating: json["rating"],
    reviewsCount: json["reviews_count"],
  );
}
