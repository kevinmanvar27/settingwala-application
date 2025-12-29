class PostaccountModel {
  bool success;
  String message;
  PostaccountModelData data;

  PostaccountModel({
    required this.success,
    required this.message,
    required this.data,
  });

}

class PostaccountModelData {
  Account account;

  PostaccountModelData({
    required this.account,
  });

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

}
