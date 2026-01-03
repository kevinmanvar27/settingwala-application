import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../model/getwalletmodel.dart';

class WalletService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetwalletModel?> getWallet() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final url = '${ApiConstants.baseUrl}/wallet';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] ?? {};
        
        return GetwalletModel(
          success: responseData['success'] ?? false,
          data: GetwalletModelData(
            balance: data['balance']?.toString() ?? '0',
            pendingBalance: _parseInt(data['pending_balance']),
            totalEarned: data['total_earned']?.toString() ?? '0',
            totalWithdrawn: data['total_withdrawn']?.toString() ?? '0',
            recentTransactions: data['recent_transactions'] ?? [],
            bankAccounts: data['bank_accounts'] ?? [],
            gpayAccounts: data['gpay_accounts'] ?? [],
            pendingWithdrawals: data['pending_withdrawals'] ?? [],
          ),
        );
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Future<GPayAccountResponse?> addGPayAccount({
    required String accountHolderName,
    required String mobileNumber,
    required String upiId,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/gpay-accounts';

      final body = {
        'account_holder_name': accountHolderName,
        'mobile_number': mobileNumber,
        'upi_id': upiId,
        'is_primary': isPrimary,
      };

      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GPayAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'G-Pay account added successfully!',
        );
      } else {
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add G-Pay account.',
        );
      }
    } catch (e) {
      
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<GPayAccountResponse?> updateGPayAccount({
    required int accountId,
    required String accountHolderName,
    required String mobileNumber,
    required String upiId,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/gpay-accounts/$accountId';

      final body = {
        'account_holder_name': accountHolderName,
        'mobile_number': mobileNumber,
        'upi_id': upiId,
        'is_primary': isPrimary,
      };

      
      
      

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return GPayAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'G-Pay account updated successfully!',
        );
      } else {
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update G-Pay account.',
        );
      }
    } catch (e) {
      
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<GPayAccountResponse?> deleteGPayAccount({
    required int accountId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/gpay-accounts/$accountId';

      
      
      

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return GPayAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'G-Pay account deleted successfully!',
        );
      } else {
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete G-Pay account.',
        );
      }
    } catch (e) {
      
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<Map<String, dynamic>?> withdrawToGPay({
    required double amount,
    required int gpayAccountId,
    String? notes,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final url = '${ApiConstants.baseUrl}/wallet/withdraw/gpay';

      final body = {
        'amount': amount,
        'gpay_account_id': gpayAccountId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Withdrawal request submitted successfully!',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to process withdrawal.',
        };
      }
    } catch (e) {
      
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ============================================
  // Bank Account Methods
  // ============================================

  /// Add a new bank account
  static Future<BankAccountResponse> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/add-bank-account';

      final body = {
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_holder_name': accountHolderName,
        'ifsc_code': ifscCode,
        'is_primary': isPrimary,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BankAccountResponse.fromJson(responseData);
      } else {
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add bank account.',
        );
      }
    } catch (e) {
      return BankAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Update an existing bank account
  static Future<BankAccountResponse> updateBankAccount({
    required int accountId,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    bool? isPrimary,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';

      final body = <String, dynamic>{};
      if (bankName != null) body['bank_name'] = bankName;
      if (accountNumber != null) body['account_number'] = accountNumber;
      if (accountHolderName != null) body['account_holder_name'] = accountHolderName;
      if (ifscCode != null) body['ifsc_code'] = ifscCode;
      if (isPrimary != null) body['is_primary'] = isPrimary;

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return BankAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Bank account updated successfully!',
        );
      } else {
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update bank account.',
        );
      }
    } catch (e) {
      return BankAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Delete a bank account
  static Future<BankAccountResponse> deleteBankAccount({
    required int accountId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return BankAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Bank account deleted successfully!',
        );
      } else {
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete bank account.',
        );
      }
    } catch (e) {
      return BankAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Request withdrawal to bank account
  static Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required int bankAccountId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return WithdrawalResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/request-withdrawal';

      final body = {
        'amount': amount,
        'bank_account_id': bankAccountId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WithdrawalResponse.fromJson(responseData);
      } else {
        return WithdrawalResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to request withdrawal.',
        );
      }
    } catch (e) {
      return WithdrawalResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Cancel a pending withdrawal request
  static Future<WithdrawalResponse> cancelWithdrawal({
    required int withdrawalId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return WithdrawalResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/cancel-withdrawal/$withdrawalId';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return WithdrawalResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Withdrawal cancelled successfully!',
        );
      } else {
        return WithdrawalResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel withdrawal.',
        );
      }
    } catch (e) {
      return WithdrawalResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Check if user can afford a specific amount
  static Future<AffordabilityResponse> checkAffordability({
    required double amount,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return AffordabilityResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/check-affordability';

      final body = {
        'amount': amount,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AffordabilityResponse.fromJson(responseData);
      } else {
        return AffordabilityResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to check affordability.',
        );
      }
    } catch (e) {
      return AffordabilityResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<WalletOverviewResponse> getWalletOverview() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return WalletOverviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return WalletOverviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return WalletOverviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return WalletOverviewResponse(
          success: false,
          message: 'Failed to get wallet overview.',
        );
      }
    } catch (e) {
      
      return WalletOverviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<WalletBalanceResponse> getBalance() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return WalletBalanceResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/wallet/balance';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return WalletBalanceResponse.fromJson(responseData);
      } else {
        return WalletBalanceResponse(
          success: false,
          message: 'Failed to get balance.',
        );
      }
    } catch (e) {
      
      return WalletBalanceResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<WalletTransactionsResponse> getTransactions({
    String? type,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return WalletTransactionsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (type != null) queryParams['type'] = type;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final url = Uri.parse('${ApiConstants.baseUrl}/wallet/transactions')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return WalletTransactionsResponse.fromJson(responseData);
      } else {
        return WalletTransactionsResponse(
          success: false,
          message: 'Failed to get transactions.',
        );
      }
    } catch (e) {
      
      return WalletTransactionsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}


class WalletOverviewResponse {
  final bool success;
  final String? message;
  final double balance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final List<WalletTransaction>? recentTransactions;

  WalletOverviewResponse({
    required this.success,
    this.message,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalWithdrawn = 0.0,
    this.recentTransactions,
  });

  factory WalletOverviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    List<WalletTransaction>? transactions;
    if (data['recent_transactions'] != null) {
      transactions = (data['recent_transactions'] as List)
          .map((t) => WalletTransaction.fromJson(t))
          .toList();
    }

    return WalletOverviewResponse(
      success: json['success'] ?? false,
      message: json['message'],
      balance: _parseDouble(data['balance']),
      pendingBalance: _parseDouble(data['pending_balance']),
      totalEarned: _parseDouble(data['total_earned']),
      totalWithdrawn: _parseDouble(data['total_withdrawn']),
      recentTransactions: transactions,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class WalletBalanceResponse {
  final bool success;
  final String? message;
  final double balance;
  final double pendingBalance;

  WalletBalanceResponse({
    required this.success,
    this.message,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return WalletBalanceResponse(
      success: json['success'] ?? false,
      message: json['message'],
      balance: _parseDouble(data['balance']),
      pendingBalance: _parseDouble(data['pending_balance']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class WalletTransactionsResponse {
  final bool success;
  final String? message;
  final List<WalletTransaction>? transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  WalletTransactionsResponse({
    required this.success,
    this.message,
    this.transactions,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    List<WalletTransaction>? transactions;
    if (data['transactions'] != null) {
      transactions = (data['transactions'] as List)
          .map((t) => WalletTransaction.fromJson(t))
          .toList();
    }

    final pagination = data['pagination'] ?? {};

    return WalletTransactionsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      transactions: transactions,
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
      total: pagination['total'] ?? 0,
    );
  }
}

class WalletTransaction {
  final int id;
  final String type;
  final double amount;
  final String? description;
  final String? status;
  final String? referenceId;
  final String? createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.status,
    this.referenceId,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: _parseDouble(json['amount']),
      description: json['description'],
      status: json['status'],
      referenceId: json['reference_id']?.toString(),
      createdAt: json['created_at'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ============================================
// GPay Account Response Model
// ============================================

class GPayAccountResponse {
  final bool success;
  final String message;

  GPayAccountResponse({
    required this.success,
    this.message = '',
  });

  factory GPayAccountResponse.fromJson(Map<String, dynamic> json) {
    return GPayAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

// ============================================
// Bank Account Models
// ============================================

class BankAccountResponse {
  final bool success;
  final String message;
  final BankAccount? account;

  BankAccountResponse({
    required this.success,
    this.message = '',
    this.account,
  });

  factory BankAccountResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      account: json['data']?['account'] != null
          ? BankAccount.fromJson(json['data']['account'])
          : null,
    );
  }
}

class BankAccount {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final bool isPrimary;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.isPrimary,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }
}

// ============================================
// Withdrawal Response Model
// ============================================

class WithdrawalResponse {
  final bool success;
  final String message;
  final int? withdrawalId;
  final double? amount;
  final String? status;

  WithdrawalResponse({
    required this.success,
    this.message = '',
    this.withdrawalId,
    this.amount,
    this.status,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return WithdrawalResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      withdrawalId: data?['withdrawal_id'],
      amount: _parseDouble(data?['amount']),
      status: data?['status'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ============================================
// Affordability Response Model
// ============================================

class AffordabilityResponse {
  final bool success;
  final String? message;
  final bool canAfford;
  final double balance;
  final double requiredAmount;
  final double shortfall;

  AffordabilityResponse({
    required this.success,
    this.message,
    this.canAfford = false,
    this.balance = 0.0,
    this.requiredAmount = 0.0,
    this.shortfall = 0.0,
  });

  factory AffordabilityResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AffordabilityResponse(
      success: json['success'] ?? false,
      message: json['message'],
      canAfford: data['can_afford'] == true,
      balance: _parseDouble(data['balance']),
      requiredAmount: _parseDouble(data['required_amount']),
      shortfall: _parseDouble(data['shortfall']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}


