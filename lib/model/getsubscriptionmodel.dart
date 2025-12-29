class GetsubscriptionModel {
  bool success;
  Data data;

  GetsubscriptionModel({
    required this.success,
    required this.data,
  });

  factory GetsubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetsubscriptionModel(
      success: json['success'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  List<Plan> plans;

  Data({
    required this.plans,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      plans: json['plans'] != null
          ? (json['plans'] as List).map((e) => Plan.fromJson(e)).toList()
          : [],
    );
  }
}

class Plan {
  int id;
  String name;
  String description;
  String amount;
  int durationMonths;
  String originalPrice;
  String? discountPrice;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.durationMonths,
    required this.originalPrice,
    required this.discountPrice,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      durationMonths: json['duration_months'] ?? 0,
      originalPrice: json['original_price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString(),
    );
  }
}
