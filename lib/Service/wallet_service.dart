import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getwalletmodel.dart';
import '../model/postaacountModel.dart';
import '../model/updateaccountmodel.dart';
import '../model/deleteaccountmodel.dart';
import '../utils/api_constants.dart';

class WalletService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Wallet API
  static Future<GetwalletModel?> getWallet() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Wallet Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseWalletResponse(json);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Wallet Error: $e');
      return null;
    }
  }

  // Parse JSON response to Model
  static GetwalletModel _parseWalletResponse(Map<String, dynamic> json) {
    final data = json['data'];

    return GetwalletModel(
      success: json['success'] ?? false,
      data: GetwalletModelData(
        balance: data?['balance']?.toString() ?? '0',
        pendingBalance: data?['pending_balance'] ?? 0,
        totalEarned: data?['total_earned']?.toString() ?? '0',
        totalWithdrawn: data?['total_withdrawn']?.toString() ?? '0',
        recentTransactions: data?['recent_transactions'] ?? [],
        bankAccounts: data?['bank_accounts'] ?? [],
        pendingWithdrawals: data?['pending_withdrawals'] ?? [],
      ),
    );
  }

  // POST Add Bank Account API
  static Future<PostaccountModel?> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/wallet/add-bank-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder_name': accountHolderName,
          'ifsc_code': ifscCode,
          'is_primary': isPrimary,
        }),
      );

      print('========== POST Add Bank Account Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return _parsePostAccountResponse(json);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('POST Add Bank Account Error: $e');
      return null;
    }
  }

  // Parse POST Account Response
  static PostaccountModel _parsePostAccountResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final account = data?['account'];

    return PostaccountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PostaccountModelData(
        account: Account(
          id: account?['id'] ?? 0,
          bankName: account?['bank_name'] ?? '',
          accountNumber: account?['account_number'] ?? '',
          accountHolderName: account?['account_holder_name'] ?? '',
          ifscCode: account?['ifsc_code'] ?? '',
          isPrimary: account?['is_primary'] == true || account?['is_primary'] == 1,
        ),
      ),
    );
  }

  // PUT Update Bank Account API
  static Future<UpdateaccountModel?> updateBankAccount({
    required int accountId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/wallet/bank-account/$accountId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder_name': accountHolderName,
          'ifsc_code': ifscCode,
          'is_primary': isPrimary,
        }),
      );

      print('========== PUT Update Bank Account Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=======================================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UpdateaccountModel(
          success: json['success'] ?? false,
          message: json['message'] ?? '',
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PUT Update Bank Account Error: $e');
      return null;
    }
  }

  // DELETE Bank Account API
  static Future<DeleteaccountModel?> deleteBankAccount({
    required int accountId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/wallet/bank-account/$accountId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE Bank Account Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return DeleteaccountModel(
          success: json['success'] ?? false,
          message: json['message'] ?? '',
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('DELETE Bank Account Error: $e');
      return null;
    }
  }
}
