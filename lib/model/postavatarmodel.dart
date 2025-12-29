class PostavatarModel {
  bool? success;
  String? message;
  PostavatarModelData? data;

  PostavatarModel({this.success, this.message, this.data});

  PostavatarModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new PostavatarModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PostavatarModelData {
  String? avatarUrl;

  PostavatarModelData({this.avatarUrl});

  PostavatarModelData.fromJson(Map<String, dynamic> json) {
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar_url'] = this.avatarUrl;
    return data;
  }
}
//api =/api/v1/profile/avatar
//post method