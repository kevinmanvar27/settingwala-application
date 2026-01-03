class Putprofilemodel {
  bool success;
  String message;
  PutprofilemodelData data;

  Putprofilemodel({
    required this.success,
    required this.message,
    required this.data,
  });

}

class PutprofilemodelData {
  User user;

  PutprofilemodelData({
    required this.user,
  });

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
  int age;
  dynamic interests;
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
  dynamic hourlyRate;
  String currency;
  dynamic serviceLocation;
  dynamic availabilitySchedule;
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

}
