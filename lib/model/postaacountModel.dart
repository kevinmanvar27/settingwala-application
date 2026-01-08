class PostaccountModel {
  bool success;
  String message;
  PostaccountModelData data;

  PostaccountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PostaccountModel.fromJson(Map<String, dynamic> json) {
    return PostaccountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PostaccountModelData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class PostaccountModelData {
  Account account;

  PostaccountModelData({
    required this.account,
  });

  factory PostaccountModelData.fromJson(Map<String, dynamic> json) {
    return PostaccountModelData(
      account: Account.fromJson(json['account'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }
}

class Account {
  int id;
  String bankName;
  String accountNumber;
  String accountHolderName;
  String ifscCode;
  bool isPrimary;

  Account({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.isPrimary,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'ifsc_code': ifscCode,
      'is_primary': isPrimary,
    };
  }
}
