class GetwalletModel {
    bool success;
    GetwalletModelData data;

    GetwalletModel({
        required this.success,
        required this.data,
    });

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

}
