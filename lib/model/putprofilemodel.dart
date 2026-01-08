class Putprofilemodel {
  bool success;
  String message;
  PutprofilemodelData data;

  Putprofilemodel({
    required this.success,
    required this.message,
    required this.data,
  });

  // Added: fromJson factory for API response deserialization
  factory Putprofilemodel.fromJson(Map<String, dynamic> json) {
    return Putprofilemodel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PutprofilemodelData.fromJson(json['data'] ?? {}),
    );
  }

  // Added: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class PutprofilemodelData {
  User user;

  PutprofilemodelData({
    required this.user,
  });

  // Added: fromJson factory for API response deserialization
  factory PutprofilemodelData.fromJson(Map<String, dynamic> json) {
    return PutprofilemodelData(
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  // Added: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }
}

class User {
  int id;
  String name;
  String email;
  String? contactNumber;
  String? profilePicture;
  String? profilePictureUrl;
  String? gender;
  DateTime? dateOfBirth;
  int? age;
  dynamic interests;
  String? expectation;
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
  dynamic hourlyRate;
  String currency;
  dynamic serviceLocation;
  dynamic availabilitySchedule;
  bool isCoupleActivityEnabled;
  String? coupleActivityStatus;
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

  User({
    required this.id,
    required this.name,
    required this.email,
    this.contactNumber,
    this.profilePicture,
    this.profilePictureUrl,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.interests,
    this.expectation,
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
    this.timeSpendingSubscriptionExpiresAt,
    this.hourlyRate,
    required this.currency,
    this.serviceLocation,
    this.availabilitySchedule,
    required this.isCoupleActivityEnabled,
    this.coupleActivityStatus,
    required this.interestedInSugarPartner,
    this.sugarPartnerTypes,
    this.sugarPartnerBio,
    this.sugarPartnerExpectations,
    required this.hideSugarPartnerNotifications,
    required this.isAdmin,
    required this.role,
    required this.isSuspended,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper to parse bool from various types
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

  // Added: fromJson factory for API response deserialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'],
      profilePicture: json['profile_picture'],
      profilePictureUrl: json['profile_picture_url'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.tryParse(json['date_of_birth']) 
          : null,
      age: json['age'],
      interests: json['interests'],
      expectation: json['expectation'],
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
      hourlyRate: json['hourly_rate'],
      currency: json['currency'] ?? 'INR',
      serviceLocation: json['service_location'],
      availabilitySchedule: json['availability_schedule'],
      isCoupleActivityEnabled: _parseBool(json['is_couple_activity_enabled']),
      coupleActivityStatus: json['couple_activity_status'],
      interestedInSugarPartner: _parseBool(json['interested_in_sugar_partner']),
      sugarPartnerTypes: json['sugar_partner_types'],
      sugarPartnerBio: json['sugar_partner_bio'],
      sugarPartnerExpectations: json['sugar_partner_expectations'],
      hideSugarPartnerNotifications: _parseBool(json['hide_sugar_partner_notifications']),
      isAdmin: _parseBool(json['is_admin']),
      role: json['role'] ?? 'user',
      isSuspended: _parseBool(json['is_suspended']),
      lastActiveAt: json['last_active_at'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Added: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact_number': contactNumber,
      'profile_picture': profilePicture,
      'profile_picture_url': profilePictureUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'age': age,
      'interests': interests,
      'expectation': expectation,
      'is_profile_complete': isProfileComplete,
      'profile_completion_percentage': profileCompletionPercentage,
      'is_public_profile': isPublicProfile,
      'show_contact_number': showContactNumber,
      'show_date_of_birth': showDateOfBirth,
      'hide_dob_year': hideDobYear,
      'show_interests_hobbies': showInterestsHobbies,
      'show_expectations': showExpectations,
      'show_gallery_images': showGalleryImages,
      'is_time_spending_enabled': isTimeSpendingEnabled,
      'has_active_time_spending_subscription': hasActiveTimeSpendingSubscription,
      'time_spending_subscription_expires_at': timeSpendingSubscriptionExpiresAt,
      'hourly_rate': hourlyRate,
      'currency': currency,
      'service_location': serviceLocation,
      'availability_schedule': availabilitySchedule,
      'is_couple_activity_enabled': isCoupleActivityEnabled,
      'couple_activity_status': coupleActivityStatus,
      'interested_in_sugar_partner': interestedInSugarPartner,
      'sugar_partner_types': sugarPartnerTypes,
      'sugar_partner_bio': sugarPartnerBio,
      'sugar_partner_expectations': sugarPartnerExpectations,
      'hide_sugar_partner_notifications': hideSugarPartnerNotifications,
      'is_admin': isAdmin,
      'role': role,
      'is_suspended': isSuspended,
      'last_active_at': lastActiveAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
