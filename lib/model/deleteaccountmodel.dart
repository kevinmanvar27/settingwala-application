class DeleteaccountModel {
  bool success;
  String message;

  DeleteaccountModel({
    required this.success,
    required this.message,
  });

  factory DeleteaccountModel.fromJson(Map<String, dynamic> json) {
    return DeleteaccountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
