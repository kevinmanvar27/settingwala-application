import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';
import '../model/getwalletmodel.dart';

class WalletService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetwalletModel?> getWallet() async {
    final url = '${ApiConstants.baseUrl}/wallet';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
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
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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

  // ============================================
  // GPay Account Methods (Uses same endpoint as Bank Account)
  // ============================================

  /// Add a new GPay account
  /// Laravel stores GPay accounts in the same table as bank accounts with payment_method_type='gpay'
  static Future<GPayAccountResponse> addGPayAccount({
    required String gpayName,
    required String gpayNumber,
  }) async {
    final url = '${ApiConstants.baseUrl}/wallet/add-bank-account';
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'payment_type': 'gpay',
        'gpay_name': gpayName,
        'gpay_number': gpayNumber,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return GPayAccountResponse(
          success: true,
          message: responseData['message'] ?? 'GPay account added successfully.',
          account: responseData['data']?['account'],
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add GPay account.',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Update an existing GPay account
  static Future<GPayAccountResponse> updateGPayAccount({
    required int accountId,
    required String gpayName,
    required String gpayNumber,
    String? gpayUpi,
  }) async {
    final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'payment_type': 'gpay',
        'gpay_name': gpayName,
        'gpay_number': gpayNumber,
      };

      if (gpayUpi != null && gpayUpi.isNotEmpty) {
        body['gpay_upi'] = gpayUpi;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return GPayAccountResponse(
          success: true,
          message: responseData['message'] ?? 'GPay account updated successfully.',
          account: responseData['data']?['account'],
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update GPay account.',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Delete a GPay account
  static Future<GPayAccountResponse> deleteGPayAccount({
    required int accountId,
  }) async {
    // FIX: Use correct endpoint /wallet/bank-account/{id} instead of /wallet/delete-bank-account/{id}
    final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';
    try {
      final token = await _getToken();

      if (token == null) {
        return GPayAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return GPayAccountResponse(
          success: true,
          message: responseData['message'] ?? 'GPay account deleted successfully.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return GPayAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete GPay account.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return GPayAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Withdraw to GPay account
  /// Uses the same requestWithdrawal endpoint - just pass the GPay account ID
  static Future<WithdrawalResponse> withdrawToGPay({
    required double amount,
    required int gpayAccountId,
    String? notes,
  }) async {
    // GPay accounts use the same withdrawal endpoint as bank accounts
    // The gpayAccountId is actually a bank_account_id in the database
    return requestWithdrawal(
      amount: amount,
      bankAccountId: gpayAccountId,
      notes: notes,
    );
  }

  // ============================================
  // Bank Account Methods
  // ============================================

  /// Add a new bank account
  /// Laravel API expects: payment_type, account_holder_name, account_number, confirm_account_number, ifsc_code, account_type
  static Future<BankAccountResponse> addBankAccount({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String accountType, // 'savings' or 'current'
  }) async {
    final url = '${ApiConstants.baseUrl}/wallet/add-bank-account';
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'payment_type': 'bank',
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'confirm_account_number': accountNumber, // Same as account_number
        'ifsc_code': ifscCode,
        'account_type': accountType,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'...': 'bank account details'});

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return BankAccountResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add bank account.',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (bankName != null) body['bank_name'] = bankName;
      if (accountNumber != null) body['account_number'] = accountNumber;
      if (accountHolderName != null) body['account_holder_name'] = accountHolderName;
      if (ifscCode != null) body['ifsc_code'] = ifscCode;
      if (isPrimary != null) body['is_primary'] = isPrimary;

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: {'...': 'bank account update'});

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return BankAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Bank account updated successfully!',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update bank account.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/wallet/bank-account/$accountId';
    try {
      final token = await _getToken();

      if (token == null) {
        return BankAccountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return BankAccountResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Bank account deleted successfully!',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BankAccountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete bank account.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BankAccountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Request withdrawal to bank account or GPay account
  /// Both bank and GPay accounts use the same endpoint with bank_account_id
  static Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required int bankAccountId,
    String? notes,
  }) async {
    final url = '${ApiConstants.baseUrl}/wallet/request-withdrawal';
    try {
      final token = await _getToken();

      if (token == null) {
        return WithdrawalResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{
        'amount': amount,
        'bank_account_id': bankAccountId,
      };

      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'amount': amount, 'bank_account_id': bankAccountId});

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return WithdrawalResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return WithdrawalResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to request withdrawal.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/wallet/cancel-withdrawal/$withdrawalId';
    try {
      final token = await _getToken();

      if (token == null) {
        return WithdrawalResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return WithdrawalResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Withdrawal cancelled successfully!',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return WithdrawalResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel withdrawal.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/wallet/check-affordability';
    try {
      final token = await _getToken();

      if (token == null) {
        return AffordabilityResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'amount': amount,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return AffordabilityResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AffordabilityResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to check affordability.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AffordabilityResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<WalletOverviewResponse> getWalletOverview() async {
    final url = '${ApiConstants.baseUrl}/wallet';
    try {
      final token = await _getToken();

      if (token == null) {
        return WalletOverviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return WalletOverviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ - Auth error
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return WalletOverviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return WalletOverviewResponse(
          success: false,
          message: 'Failed to get wallet overview.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return WalletOverviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<WalletBalanceResponse> getBalance() async {
    final url = '${ApiConstants.baseUrl}/wallet/balance';
    try {
      final token = await _getToken();

      if (token == null) {
        return WalletBalanceResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return WalletBalanceResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return WalletBalanceResponse(
          success: false,
          message: 'Failed to get balance.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final baseUrl = '${ApiConstants.baseUrl}/wallet/transactions';
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

      final url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url.toString(), method: 'GET');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url.toString(), statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return WalletTransactionsResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url.toString(), statusCode: response.statusCode);
        return WalletTransactionsResponse(
          success: false,
          message: 'Failed to get transactions.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: baseUrl, error: e.toString());
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
  final List<BankAccount>? bankAccounts;
  final List<PendingWithdrawal>? pendingWithdrawals;

  WalletOverviewResponse({
    required this.success,
    this.message,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalWithdrawn = 0.0,
    this.recentTransactions,
    this.bankAccounts,
    this.pendingWithdrawals,
  });

  factory WalletOverviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    List<WalletTransaction>? transactions;
    if (data['recent_transactions'] != null) {
      transactions = (data['recent_transactions'] as List)
          .map((t) => WalletTransaction.fromJson(t))
          .toList();
    }

    List<BankAccount>? accounts;
    if (data['bank_accounts'] != null) {
      accounts = (data['bank_accounts'] as List)
          .map((a) => BankAccount.fromJson(a))
          .toList();
    }

    List<PendingWithdrawal>? withdrawals;
    if (data['pending_withdrawals'] != null) {
      withdrawals = (data['pending_withdrawals'] as List)
          .map((w) => PendingWithdrawal.fromJson(w))
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
      bankAccounts: accounts,
      pendingWithdrawals: withdrawals,
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

/// Model for pending withdrawal requests
class PendingWithdrawal {
  final int id;
  final double amount;
  final String status;
  final DateTime? createdAt;

  PendingWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  factory PendingWithdrawal.fromJson(Map<String, dynamic> json) {
    return PendingWithdrawal(
      id: json['id'] ?? 0,
      amount: _parseDouble(json['amount']),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
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
  final Map<String, dynamic>? account;
  final Map<String, dynamic>? errors;

  GPayAccountResponse({
    required this.success,
    this.message = '',
    this.account,
    this.errors,
  });

  factory GPayAccountResponse.fromJson(Map<String, dynamic> json) {
    return GPayAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      account: json['data']?['account'],
      errors: json['errors'],
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
  final Map<String, dynamic>? errors;

  BankAccountResponse({
    required this.success,
    this.message = '',
    this.account,
    this.errors,
  });

  factory BankAccountResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      account: json['data']?['account'] != null
          ? BankAccount.fromJson(json['data']['account'])
          : null,
      errors: json['errors'],
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
  final String paymentMethodType; // 'bank' or 'gpay'
  final String? gpayName;
  final String? gpayNumber;
  final String? gpayUpi;
  final String? accountType; // 'savings' or 'current'

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.isPrimary,
    this.paymentMethodType = 'bank',
    this.gpayName,
    this.gpayNumber,
    this.gpayUpi,
    this.accountType,
  });

  // Helper to check if this is a GPay account
  bool get isGPay => paymentMethodType == 'gpay';

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      isPrimary: json['is_primary'] == true,
      paymentMethodType: json['payment_method_type'] ?? 'bank',
      gpayName: json['gpay_name'],
      gpayNumber: json['gpay_number'],
      gpayUpi: json['gpay_upi'],
      accountType: json['account_type'],
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


