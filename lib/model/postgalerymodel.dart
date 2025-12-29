class postgalerymodel {
  bool? success;
  String? message;
  postgalerymodelData? data;

  postgalerymodel({this.success, this.message, this.data});

  postgalerymodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new postgalerymodelData.fromJson(json['data']) : null;
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

class postgalerymodelData {
  int? id;
  String? url;
  String? originalName;
  int? sortOrder;

  postgalerymodelData({this.id, this.url, this.originalName, this.sortOrder});

  postgalerymodelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    originalName = json['original_name'];
    sortOrder = json['sort_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['original_name'] = this.originalName;
    data['sort_order'] = this.sortOrder;
    return data;
  }
}
// api =/api/v1/gallery/upload post method