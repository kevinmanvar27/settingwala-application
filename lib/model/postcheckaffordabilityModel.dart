class PostcheckaffordabilityModel {
  bool success;
  PostcheckaffordabilityModelData data;

  PostcheckaffordabilityModel({
    required this.success,
    required this.data,
  });

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

}
