class GetwalletModel {
    bool success;
    GetwalletModelData data;

    GetwalletModel({
        required this.success,
        required this.data,
    });

    // Added: fromJson factory for API response deserialization
    factory GetwalletModel.fromJson(Map<String, dynamic> json) {
        return GetwalletModel(
            success: json['success'] ?? false,
            data: GetwalletModelData.fromJson(json['data'] ?? {}),
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

class GetwalletModelData {
    String balance;
    int pendingBalance;
    String totalEarned;
    String totalWithdrawn;
    List<dynamic> recentTransactions;
    List<dynamic> bankAccounts;
    List<dynamic> gpayAccounts;
    List<dynamic> pendingWithdrawals;

    GetwalletModelData({
        required this.balance,
        required this.pendingBalance,
        required this.totalEarned,
        required this.totalWithdrawn,
        required this.recentTransactions,
        required this.bankAccounts,
        required this.gpayAccounts,
        required this.pendingWithdrawals,
    });

    // Added: fromJson factory for API response deserialization
    factory GetwalletModelData.fromJson(Map<String, dynamic> json) {
        return GetwalletModelData(
            balance: json['balance']?.toString() ?? '0',
            pendingBalance: json['pending_balance'] ?? 0,
            totalEarned: json['total_earned']?.toString() ?? '0',
            totalWithdrawn: json['total_withdrawn']?.toString() ?? '0',
            recentTransactions: json['recent_transactions'] ?? [],
            bankAccounts: json['bank_accounts'] ?? [],
            gpayAccounts: json['gpay_accounts'] ?? [],
            pendingWithdrawals: json['pending_withdrawals'] ?? [],
        );
    }

    // Added: toJson method for serialization
    Map<String, dynamic> toJson() {
        return {
            'balance': balance,
            'pending_balance': pendingBalance,
            'total_earned': totalEarned,
            'total_withdrawn': totalWithdrawn,
            'recent_transactions': recentTransactions,
            'bank_accounts': bankAccounts,
            'gpay_accounts': gpayAccounts,
            'pending_withdrawals': pendingWithdrawals,
        };
    }
}
