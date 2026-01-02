import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getusersmodel.dart';
import '../model/getuseravailabilitymodel.dart';
import '../utils/api_constants.dart';


class ReviewerInfo {
  final int id;
  final String name;
  final String? profilePicture;

  ReviewerInfo({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }
}

class UserReviewItem {
  final int id;
  final double rating;
  final String? review;
  final ReviewerInfo? reviewer;
  final DateTime createdAt;

  UserReviewItem({
    required this.id,
    required this.rating,
    this.review,
    this.reviewer,
    required this.createdAt,
  });

  factory UserReviewItem.fromJson(Map<String, dynamic> json) {
    return UserReviewItem(
      id: json['id'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      review: json['review'],
      reviewer: json['reviewer'] != null 
          ? ReviewerInfo.fromJson(json['reviewer']) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ReviewsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ReviewsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ReviewsPagination.fromJson(Map<String, dynamic> json) {
    return ReviewsPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

class UserReviewsResponse {
  final bool success;
  final List<UserReviewItem> reviews;
  final double averageRating;
  final int totalReviews;
  final ReviewsPagination pagination;

  UserReviewsResponse({
    required this.success,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.pagination,
  });

  factory UserReviewsResponse.fromJson(Map<String, dynamic> json) {
    List<UserReviewItem> reviewsList = [];
    if (json['data']?['reviews'] != null) {
      for (var item in json['data']['reviews']) {
        reviewsList.add(UserReviewItem.fromJson(item));
      }
    }

    return UserReviewsResponse(
      success: json['success'] ?? false,
      reviews: reviewsList,
      averageRating: (json['data']?['average_rating'] ?? 0).toDouble(),
      totalReviews: json['data']?['total_reviews'] ?? 0,
      pagination: ReviewsPagination.fromJson(json['data']?['pagination'] ?? {}),
    );
  }
}

class ReportUserResponse {
  final bool success;
  final String message;
  final int? reportId;

  ReportUserResponse({
    required this.success,
    required this.message,
    this.reportId,
  });

  factory ReportUserResponse.fromJson(Map<String, dynamic> json) {
    return ReportUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      reportId: json['data']?['report_id'],
    );
  }
}


class UserService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Getusersmodel?> getUsers({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Getusersmodel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<Getuseravailabilitymodel?> getUserAvailability({
    required int userId,
    required DateTime date,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      
      
      

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/availability?date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Getuseravailabilitymodel.fromJson(json);
      } else if (response.statusCode == 401) {
        
        return null;
      } else if (response.statusCode == 404) {
        
        return null;
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }


  static Future<UserReviewsResponse?> getUserReviews({
    required int userId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final url = '${ApiConstants.baseUrl}/users/$userId/reviews?page=$page&per_page=$perPage';
      
      
      
      
      
      
      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = UserReviewsResponse.fromJson(json);
        
        
        
        
        
        return result;
      } else if (response.statusCode == 404) {
        
        return null;
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<ReportUserResponse?> reportUser({
    required int userId,
    required String category,
    required String description,
    List<String>? evidencePaths,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final url = '${ApiConstants.baseUrl}/users/$userId/report';
      
      
      
      
      
      
      
      
      
      

      if (evidencePaths != null && evidencePaths.isNotEmpty) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
        
        request.fields['category'] = category;
        request.fields['description'] = description;
        
        for (var path in evidencePaths) {
          request.files.add(await http.MultipartFile.fromPath('evidence[]', path));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        
        

        if (response.statusCode == 200 || response.statusCode == 201) {
          final json = jsonDecode(response.body);
          final result = ReportUserResponse.fromJson(json);
          
          
          return result;
        } else if (response.statusCode == 400) {
          final json = jsonDecode(response.body);
          
          return ReportUserResponse.fromJson(json);
        } else if (response.statusCode == 404) {
          
          return null;
        } else if (response.statusCode == 422) {
          
          return null;
        } else {
          
          return null;
        }
      } else {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'category': category,
            'description': description,
          }),
        );

        
        

        if (response.statusCode == 200 || response.statusCode == 201) {
          final json = jsonDecode(response.body);
          final result = ReportUserResponse.fromJson(json);
          
          
          return result;
        } else if (response.statusCode == 400) {
          final json = jsonDecode(response.body);
          
          return ReportUserResponse.fromJson(json);
        } else if (response.statusCode == 404) {
          
          return null;
        } else if (response.statusCode == 422) {
          
          return null;
        } else {
          
          return null;
        }
      }
    } catch (e) {
      
      return null;
    }
  }

  static List<String> get reportCategories => [
    'harassment',
    'fake_profile',
    'inappropriate_content',
    'spam',
    'scam',
    'other',
  ];

  static String getReportCategoryLabel(String category) {
    switch (category) {
      case 'harassment':
        return 'Harassment';
      case 'fake_profile':
        return 'Fake Profile';
      case 'inappropriate_content':
        return 'Inappropriate Content';
      case 'spam':
        return 'Spam';
      case 'scam':
        return 'Scam';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}
