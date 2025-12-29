class GetProfileModel {
  bool? success;
  GetProfileModelData? data;

  GetProfileModel({this.success, this.data});

  GetProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? GetProfileModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class GetProfileModelData {
  User? user;
  List<dynamic>? gallery;
  dynamic subscription;
  Features? features;

  GetProfileModelData({this.user, this.gallery, this.subscription, this.features});

  GetProfileModelData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['gallery'] != null) {
      gallery = List<dynamic>.from(json['gallery']);
    }
    subscription = json['subscription'];
    features = json['features'] != null ? Features.fromJson(json['features']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    if (gallery != null) {
      json['gallery'] = gallery;
    }
    json['subscription'] = subscription;
    if (features != null) {
      json['features'] = features!.toJson();
    }
    return json;
  }
}

class Features {
  bool? timeSpending;
  bool? gallery;
  bool? partnerSwapping;
  bool? sugarPartner;
  bool? subscriptionModel;

  Features({
    this.timeSpending,
    this.gallery,
    this.partnerSwapping,
    this.sugarPartner,
    this.subscriptionModel,
  });

  // Helper function to parse bool from int/bool/string
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  Features.fromJson(Map<String, dynamic> json) {
    timeSpending = _parseBool(json['time_spending']);
    gallery = _parseBool(json['gallery']);
    partnerSwapping = _parseBool(json['partner_swapping']);
    sugarPartner = _parseBool(json['sugar_partner']);
    subscriptionModel = _parseBool(json['subscription_model']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['time_spending'] = timeSpending;
    json['gallery'] = gallery;
    json['partner_swapping'] = partnerSwapping;
    json['sugar_partner'] = sugarPartner;
    json['subscription_model'] = subscriptionModel;
    return json;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic contactNumber;
  dynamic profilePicture;
  dynamic profilePictureUrl;
  dynamic gender;
  dynamic dateOfBirth;
  dynamic age;
  // Location fields
  dynamic city;
  dynamic state;
  dynamic country;
  // Physical attributes
  dynamic height;
  dynamic weight;
  dynamic bodyType;
  // Professional
  dynamic education;
  dynamic occupation;
  dynamic income;
  // Lifestyle
  dynamic relationshipStatus;
  dynamic smoking;
  dynamic drinking;
  // Interests and expectations
  dynamic interests;
  dynamic languages;
  dynamic expectation;  // Partner expectations field
  // Profile status
  bool? isProfileComplete;
  int? profileCompletionPercentage;
  // Privacy settings
  bool? isPublicProfile;
  bool? showContactNumber;
  bool? showDateOfBirth;
  bool? hideDobYear;
  bool? showInterestsHobbies;
  bool? showExpectations;
  bool? showGalleryImages;
  // Time spending
  bool? isTimeSpendingEnabled;
  bool? hasActiveTimeSpendingSubscription;
  dynamic timeSpendingSubscriptionExpiresAt;
  dynamic hourlyRate;
  dynamic currency;
  dynamic serviceLocation;
  dynamic availabilitySchedule;
  // Couple activity
  bool? isCoupleActivityEnabled;
  dynamic coupleActivityStatus;
  // Sugar partner
  bool? interestedInSugarPartner;
  dynamic sugarPartnerTypes;
  dynamic sugarPartnerBio;
  dynamic sugarPartnerExpectations;
  bool? hideSugarPartnerNotifications;
  // Admin
  bool? isAdmin;
  dynamic role;
  bool? isSuspended;
  dynamic lastActiveAt;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.contactNumber,
    this.profilePicture,
    this.profilePictureUrl,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.city,
    this.state,
    this.country,
    this.height,
    this.weight,
    this.bodyType,
    this.education,
    this.occupation,
    this.income,
    this.relationshipStatus,
    this.smoking,
    this.drinking,
    this.interests,
    this.languages,
    this.expectation,
    this.isProfileComplete,
    this.profileCompletionPercentage,
    this.isPublicProfile,
    this.showContactNumber,
    this.showDateOfBirth,
    this.hideDobYear,
    this.showInterestsHobbies,
    this.showExpectations,
    this.showGalleryImages,
    this.isTimeSpendingEnabled,
    this.hasActiveTimeSpendingSubscription,
    this.timeSpendingSubscriptionExpiresAt,
    this.hourlyRate,
    this.currency,
    this.serviceLocation,
    this.availabilitySchedule,
    this.isCoupleActivityEnabled,
    this.coupleActivityStatus,
    this.interestedInSugarPartner,
    this.sugarPartnerTypes,
    this.sugarPartnerBio,
    this.sugarPartnerExpectations,
    this.hideSugarPartnerNotifications,
    this.isAdmin,
    this.role,
    this.isSuspended,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
  });

  // Helper function to parse bool from int/bool/string
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    contactNumber = json['contact_number'];
    profilePicture = json['profile_picture'];
    profilePictureUrl = json['profile_picture_url'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    age = json['age'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    height = json['height'];
    weight = json['weight'];
    bodyType = json['body_type'];
    education = json['education'];
    occupation = json['occupation'];
    income = json['income'];
    relationshipStatus = json['relationship_status'];
    smoking = json['smoking'];
    drinking = json['drinking'];
    interests = json['interests'];
    languages = json['languages'];
    expectation = json['expectation'];
    isProfileComplete = _parseBool(json['is_profile_complete']);
    profileCompletionPercentage = json['profile_completion_percentage'];
    isPublicProfile = _parseBool(json['is_public_profile']);
    showContactNumber = _parseBool(json['show_contact_number']);
    showDateOfBirth = _parseBool(json['show_date_of_birth']);
    hideDobYear = _parseBool(json['hide_dob_year']);
    showInterestsHobbies = _parseBool(json['show_interests_hobbies']);
    showExpectations = _parseBool(json['show_expectations']);
    showGalleryImages = _parseBool(json['show_gallery_images']);
    isTimeSpendingEnabled = _parseBool(json['is_time_spending_enabled']);
    hasActiveTimeSpendingSubscription = _parseBool(json['has_active_time_spending_subscription']);
    timeSpendingSubscriptionExpiresAt = json['time_spending_subscription_expires_at'];
    hourlyRate = json['hourly_rate'];
    currency = json['currency'];
    serviceLocation = json['service_location'];
    availabilitySchedule = json['availability_schedule'];
    isCoupleActivityEnabled = _parseBool(json['is_couple_activity_enabled']);
    coupleActivityStatus = json['couple_activity_status'];
    interestedInSugarPartner = _parseBool(json['interested_in_sugar_partner']);
    sugarPartnerTypes = json['sugar_partner_types'];
    sugarPartnerBio = json['sugar_partner_bio'];
    sugarPartnerExpectations = json['sugar_partner_expectations'];
    hideSugarPartnerNotifications = _parseBool(json['hide_sugar_partner_notifications']);
    isAdmin = _parseBool(json['is_admin']);
    role = json['role'];
    isSuspended = _parseBool(json['is_suspended']);
    lastActiveAt = json['last_active_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['id'] = id;
    json['name'] = name;
    json['email'] = email;
    json['contact_number'] = contactNumber;
    json['profile_picture'] = profilePicture;
    json['profile_picture_url'] = profilePictureUrl;
    json['gender'] = gender;
    json['date_of_birth'] = dateOfBirth;
    json['age'] = age;
    json['city'] = city;
    json['state'] = state;
    json['country'] = country;
    json['height'] = height;
    json['weight'] = weight;
    json['body_type'] = bodyType;
    json['education'] = education;
    json['occupation'] = occupation;
    json['income'] = income;
    json['relationship_status'] = relationshipStatus;
    json['smoking'] = smoking;
    json['drinking'] = drinking;
    json['interests'] = interests;
    json['languages'] = languages;
    json['expectation'] = expectation;
    json['is_profile_complete'] = isProfileComplete;
    json['profile_completion_percentage'] = profileCompletionPercentage;
    json['is_public_profile'] = isPublicProfile;
    json['show_contact_number'] = showContactNumber;
    json['show_date_of_birth'] = showDateOfBirth;
    json['hide_dob_year'] = hideDobYear;
    json['show_interests_hobbies'] = showInterestsHobbies;
    json['show_expectations'] = showExpectations;
    json['show_gallery_images'] = showGalleryImages;
    json['is_time_spending_enabled'] = isTimeSpendingEnabled;
    json['has_active_time_spending_subscription'] = hasActiveTimeSpendingSubscription;
    json['time_spending_subscription_expires_at'] = timeSpendingSubscriptionExpiresAt;
    json['hourly_rate'] = hourlyRate;
    json['currency'] = currency;
    json['service_location'] = serviceLocation;
    json['availability_schedule'] = availabilitySchedule;
    json['is_couple_activity_enabled'] = isCoupleActivityEnabled;
    json['couple_activity_status'] = coupleActivityStatus;
    json['interested_in_sugar_partner'] = interestedInSugarPartner;
    json['sugar_partner_types'] = sugarPartnerTypes;
    json['sugar_partner_bio'] = sugarPartnerBio;
    json['sugar_partner_expectations'] = sugarPartnerExpectations;
    json['hide_sugar_partner_notifications'] = hideSugarPartnerNotifications;
    json['is_admin'] = isAdmin;
    json['role'] = role;
    json['is_suspended'] = isSuspended;
    json['last_active_at'] = lastActiveAt;
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    return json;
  }
}