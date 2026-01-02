class PuttimespendingModel {
  bool success;
  String message;
  PuttimespendingModelData data;

  PuttimespendingModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PuttimespendingModel.fromJson(Map<String, dynamic> json) {
    return PuttimespendingModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PuttimespendingModelData.fromJson(json['data'] ?? {}),
    );
  }
}

class PuttimespendingModelData {
  User user;

  PuttimespendingModelData({
    required this.user,
  });

  factory PuttimespendingModelData.fromJson(Map<String, dynamic> json) {
    return PuttimespendingModelData(
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  int id;
  String name;
  String email;
  String contactNumber;
  String profilePicture;
  String profilePictureUrl;
  String gender;
  DateTime dateOfBirth;
  double age;
  String interests;
  String expectation;
  bool isProfileComplete;
  int profileCompletionPercentage;
  bool isPublicProfile;
  bool showContactNumber;
  bool showDateOfBirth;
  bool hideDobYear;
  bool showInterestsHobbies;
  bool showExpectations;
  bool showGalleryImages;
  bool isTimeSpendingEnabled;
  bool hasActiveTimeSpendingSubscription;
  dynamic timeSpendingSubscriptionExpiresAt;
  String hourlyRate;
  String currency;
  String serviceLocation;
  AvailabilitySchedule availabilitySchedule;
  bool isCoupleActivityEnabled;
  String coupleActivityStatus;
  bool interestedInSugarPartner;
  dynamic sugarPartnerTypes;
  dynamic sugarPartnerBio;
  dynamic sugarPartnerExpectations;
  bool hideSugarPartnerNotifications;
  bool isAdmin;
  String role;
  bool isSuspended;
  dynamic lastActiveAt;
  DateTime createdAt;
  DateTime updatedAt;

  static bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return defaultValue;
  }

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.profilePicture,
    required this.profilePictureUrl,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.interests,
    required this.expectation,
    required this.isProfileComplete,
    required this.profileCompletionPercentage,
    required this.isPublicProfile,
    required this.showContactNumber,
    required this.showDateOfBirth,
    required this.hideDobYear,
    required this.showInterestsHobbies,
    required this.showExpectations,
    required this.showGalleryImages,
    required this.isTimeSpendingEnabled,
    required this.hasActiveTimeSpendingSubscription,
    required this.timeSpendingSubscriptionExpiresAt,
    required this.hourlyRate,
    required this.currency,
    required this.serviceLocation,
    required this.availabilitySchedule,
    required this.isCoupleActivityEnabled,
    required this.coupleActivityStatus,
    required this.interestedInSugarPartner,
    required this.sugarPartnerTypes,
    required this.sugarPartnerBio,
    required this.sugarPartnerExpectations,
    required this.hideSugarPartnerNotifications,
    required this.isAdmin,
    required this.role,
    required this.isSuspended,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : DateTime.now(),
      age: (json['age'] ?? 0).toDouble(),
      interests: json['interests'] ?? '',
      expectation: json['expectation'] ?? '',
      isProfileComplete: _parseBool(json['is_profile_complete']),
      profileCompletionPercentage: json['profile_completion_percentage'] ?? 0,
      isPublicProfile: _parseBool(json['is_public_profile']),
      showContactNumber: _parseBool(json['show_contact_number']),
      showDateOfBirth: _parseBool(json['show_date_of_birth']),
      hideDobYear: _parseBool(json['hide_dob_year']),
      showInterestsHobbies: _parseBool(json['show_interests_hobbies']),
      showExpectations: _parseBool(json['show_expectations']),
      showGalleryImages: _parseBool(json['show_gallery_images']),
      isTimeSpendingEnabled: _parseBool(json['is_time_spending_enabled']),
      hasActiveTimeSpendingSubscription: _parseBool(json['has_active_time_spending_subscription']),
      timeSpendingSubscriptionExpiresAt: json['time_spending_subscription_expires_at'],
      hourlyRate: json['hourly_rate']?.toString() ?? '0',
      currency: json['currency'] ?? 'INR',
      serviceLocation: json['service_location'] ?? '',
      availabilitySchedule: json['availability_schedule'] != null
          ? AvailabilitySchedule.fromJson(json['availability_schedule'])
          : AvailabilitySchedule.empty(),
      isCoupleActivityEnabled: _parseBool(json['is_couple_activity_enabled']),
      coupleActivityStatus: json['couple_activity_status'] ?? '',
      interestedInSugarPartner: _parseBool(json['interested_in_sugar_partner']),
      sugarPartnerTypes: json['sugar_partner_types'],
      sugarPartnerBio: json['sugar_partner_bio'],
      sugarPartnerExpectations: json['sugar_partner_expectations'],
      hideSugarPartnerNotifications: _parseBool(json['hide_sugar_partner_notifications']),
      isAdmin: _parseBool(json['is_admin']),
      role: json['role'] ?? '',
      isSuspended: _parseBool(json['is_suspended']),
      lastActiveAt: json['last_active_at'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

class AvailabilitySchedule {
  Day sunday;
  Day monday;
  Day tuesday;
  Day wednesday;
  Day thursday;
  Day friday;
  Day saturday;

  AvailabilitySchedule({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory AvailabilitySchedule.fromJson(Map<String, dynamic> json) {
    return AvailabilitySchedule(
      sunday: Day.fromJson(json['sunday'] ?? {}),
      monday: Day.fromJson(json['monday'] ?? {}),
      tuesday: Day.fromJson(json['tuesday'] ?? {}),
      wednesday: Day.fromJson(json['wednesday'] ?? {}),
      thursday: Day.fromJson(json['thursday'] ?? {}),
      friday: Day.fromJson(json['friday'] ?? {}),
      saturday: Day.fromJson(json['saturday'] ?? {}),
    );
  }

  factory AvailabilitySchedule.empty() {
    return AvailabilitySchedule(
      sunday: Day.empty(),
      monday: Day.empty(),
      tuesday: Day.empty(),
      wednesday: Day.empty(),
      thursday: Day.empty(),
      friday: Day.empty(),
      saturday: Day.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunday': sunday.toJson(),
      'monday': monday.toJson(),
      'tuesday': tuesday.toJson(),
      'wednesday': wednesday.toJson(),
      'thursday': thursday.toJson(),
      'friday': friday.toJson(),
      'saturday': saturday.toJson(),
    };
  }
}

class Day {
  String startTime;
  String endTime;
  bool isHoliday;

  Day({
    required this.startTime,
    required this.endTime,
    required this.isHoliday,
  });

  static bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return defaultValue;
  }

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      startTime: json['start_time'] ?? '09:00',
      endTime: json['end_time'] ?? '17:00',
      isHoliday: _parseBool(json['is_holiday']),
    );
  }

  factory Day.empty() {
    return Day(
      startTime: '09:00',
      endTime: '17:00',
      isHoliday: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'is_holiday': isHoliday,
    };
  }
}
