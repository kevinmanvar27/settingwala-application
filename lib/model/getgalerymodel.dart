
class GetgaleryModel {
  bool? success;
  GetgaleryModelData? data;

  GetgaleryModel({this.success, this.data});

  GetgaleryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new GetgaleryModelData.fromJson(json['data']) : null;
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

class GetgaleryModelData {
  List<Gallery>? gallery;

  GetgaleryModelData({this.gallery});

  GetgaleryModelData.fromJson(Map<String, dynamic> json) {
    if (json['gallery'] != null) {
      gallery = <Gallery>[];
      json['gallery'].forEach((v) {
        gallery!.add(new Gallery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gallery != null) {
      data['gallery'] = this.gallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gallery {
  int? id;
  String? url;
  String? originalName;
  int? sortOrder;
  bool? isActive;
  String? createdAt;

  Gallery(
      {this.id,
        this.url,
        this.originalName,
        this.sortOrder,
        this.isActive,
        this.createdAt});

  Gallery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    originalName = json['original_name'];
    sortOrder = json['sort_order'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['original_name'] = this.originalName;
    data['sort_order'] = this.sortOrder;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    return data;
  }
}
