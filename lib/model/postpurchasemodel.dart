
import 'dart:convert';

PostpurchaseModel postpurchaseModelFromJson(String str) => PostpurchaseModel.fromJson(json.decode(str));

String postpurchaseModelToJson(PostpurchaseModel data) => json.encode(data.toJson());

class PostpurchaseModel {
  bool success;
  PostpurchaseModelData data;

  PostpurchaseModel({
    required this.success,
    required this.data,
  });

  factory PostpurchaseModel.fromJson(Map<String, dynamic> json) => PostpurchaseModel(
    success: json["success"],
    data: PostpurchaseModelData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class PostpurchaseModelData {
  bool paymentCompleted;
  int subscriptionId;
  String amount;
  String planName;
  CashfreeOrder cashfreeOrder;
  String cashfreeKey;
  String cashfreeEnv;

  PostpurchaseModelData({
    required this.paymentCompleted,
    required this.subscriptionId,
    required this.amount,
    required this.planName,
    required this.cashfreeOrder,
    required this.cashfreeKey,
    required this.cashfreeEnv,
  });

  factory PostpurchaseModelData.fromJson(Map<String, dynamic> json) => PostpurchaseModelData(
    paymentCompleted: json["payment_completed"],
    subscriptionId: json["subscription_id"],
    amount: json["amount"],
    planName: json["plan_name"],
    cashfreeOrder: CashfreeOrder.fromJson(json["cashfree_order"]),
    cashfreeKey: json["cashfree_key"],
    cashfreeEnv: json["cashfree_env"],
  );

  Map<String, dynamic> toJson() => {
    "payment_completed": paymentCompleted,
    "subscription_id": subscriptionId,
    "amount": amount,
    "plan_name": planName,
    "cashfree_order": cashfreeOrder.toJson(),
    "cashfree_key": cashfreeKey,
    "cashfree_env": cashfreeEnv,
  };
}

class CashfreeOrder {
  String orderId;
  String cfOrderId;
  String paymentSessionId;
  String orderStatus;

  CashfreeOrder({
    required this.orderId,
    required this.cfOrderId,
    required this.paymentSessionId,
    required this.orderStatus,
  });

  factory CashfreeOrder.fromJson(Map<String, dynamic> json) => CashfreeOrder(
    orderId: json["order_id"],
    cfOrderId: json["cf_order_id"],
    paymentSessionId: json["payment_session_id"],
    orderStatus: json["order_status"],
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "cf_order_id": cfOrderId,
    "payment_session_id": paymentSessionId,
    "order_status": orderStatus,
  };
}
