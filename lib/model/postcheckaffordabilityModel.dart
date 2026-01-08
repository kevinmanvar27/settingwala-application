class PostcheckaffordabilityModel {
  bool success;
  PostcheckaffordabilityModelData data;

  PostcheckaffordabilityModel({
    required this.success,
    required this.data,
  });

  // Added: fromJson factory for API response deserialization
  factory PostcheckaffordabilityModel.fromJson(Map<String, dynamic> json) {
    return PostcheckaffordabilityModel(
      success: json['success'] ?? false,
      data: PostcheckaffordabilityModelData.fromJson(json['data'] ?? {}),
    );
  }

  // Added: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PostcheckaffordabilityModelData {
  bool canAfford;
  String balance;
  int requiredAmount;
  int shortfall;

  PostcheckaffordabilityModelData({
    required this.canAfford,
    required this.balance,
    required this.requiredAmount,
    required this.shortfall,
  });

  // Added: fromJson factory for API response deserialization
  factory PostcheckaffordabilityModelData.fromJson(Map<String, dynamic> json) {
    return PostcheckaffordabilityModelData(
      canAfford: json['can_afford'] ?? false,
      balance: json['balance']?.toString() ?? '0',
      requiredAmount: json['required_amount'] ?? 0,
      shortfall: json['shortfall'] ?? 0,
    );
  }

  // Added: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'can_afford': canAfford,
      'balance': balance,
      'required_amount': requiredAmount,
      'shortfall': shortfall,
    };
  }
}
