class UpdateaccountModel {
  bool success;
  String message;

  UpdateaccountModel({
    required this.success,
    required this.message,
  });

  factory UpdateaccountModel.fromJson(Map<String, dynamic> json) {
    return UpdateaccountModel(
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
