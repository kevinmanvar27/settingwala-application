class GetcompletionstatusModel {
  bool? success;
  GetcompletionstatusModelData? data;

  GetcompletionstatusModel({this.success, this.data});

  GetcompletionstatusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new GetcompletionstatusModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GetcompletionstatusModelData {
  bool? isComplete;
  int? percentage;
  Fields? fields;
  List<String>? missingFields;

  GetcompletionstatusModelData({this.isComplete, this.percentage, this.fields, this.missingFields});

  GetcompletionstatusModelData.fromJson(Map<String, dynamic> json) {
    isComplete = json['is_complete'];
    percentage = json['percentage'];
    fields =
    json['fields'] != null ? new Fields.fromJson(json['fields']) : null;
    missingFields = json['missing_fields'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_complete'] = this.isComplete;
    data['percentage'] = this.percentage;
    if (this.fields != null) {
      data['fields'] = this.fields!.toJson();
    }
    data['missing_fields'] = this.missingFields;
    return data;
  }
}

class Fields {
  bool? name;
  bool? email;
  bool? phone;
  bool? gender;
  bool? dateOfBirth;
  bool? bio;
  bool? city;
  bool? avatar;
  bool? gallery;

  Fields(
      {this.name,
        this.email,
        this.phone,
        this.gender,
        this.dateOfBirth,
        this.bio,
        this.city,
        this.avatar,
        this.gallery});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    bio = json['bio'];
    city = json['city'];
    avatar = json['avatar'];
    gallery = json['gallery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['bio'] = this.bio;
    data['city'] = this.city;
    data['avatar'] = this.avatar;
    data['gallery'] = this.gallery;
    return data;
  }
}
