import 'dart:developer' as developer;

/// API Logger - બધી API calls માટે ગુજરાતી logging
class ApiLogger {
  static const String _tag = '🌐 API';

  /// API call થઈ ત્યારે log કરો
  static void logApiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) {
    developer.log(
      '✅ API CALL થઈ ગઈ!\n'
      '📍 Endpoint: $endpoint\n'
      '📝 Method: $method\n'
      '${body != null ? '📦 Body: $body' : ''}',
      name: _tag,
    );
    print('═══════════════════════════════════════════════════════════');
    print('✅ API CALL થઈ ગઈ!');
    print('📍 Endpoint: $endpoint');
    print('📝 Method: $method');
    if (body != null) print('📦 Body: $body');
    print('═══════════════════════════════════════════════════════════');
  }

  /// API call સફળ થઈ ત્યારે log કરો
  static void logApiSuccess({
    required String endpoint,
    required int statusCode,
    dynamic response,
  }) {
    developer.log(
      '🎉 API CALL સફળ થઈ!\n'
      '📍 Endpoint: $endpoint\n'
      '📊 Status Code: $statusCode\n'
      '${response != null ? '📥 Response: $response' : ''}',
      name: _tag,
    );
    print('═══════════════════════════════════════════════════════════');
    print('🎉 API CALL સફળ થઈ!');
    print('📍 Endpoint: $endpoint');
    print('📊 Status Code: $statusCode');
    print('═══════════════════════════════════════════════════════════');
  }

  /// API call નિષ્ફળ થઈ ત્યારે log કરો
  static void logApiError({
    required String endpoint,
    int? statusCode,
    String? error,
  }) {
    developer.log(
      '❌ API CALL નિષ્ફળ થઈ!\n'
      '📍 Endpoint: $endpoint\n'
      '${statusCode != null ? '📊 Status Code: $statusCode\n' : ''}'
      '${error != null ? '⚠️ Error: $error' : ''}',
      name: _tag,
    );
    print('═══════════════════════════════════════════════════════════');
    print('❌ API CALL નિષ્ફળ થઈ!');
    print('📍 Endpoint: $endpoint');
    if (statusCode != null) print('📊 Status Code: $statusCode');
    if (error != null) print('⚠️ Error: $error');
    print('═══════════════════════════════════════════════════════════');
  }

  /// Network error ત્યારે log કરો
  static void logNetworkError({
    required String endpoint,
    required String error,
  }) {
    developer.log(
      '🔌 NETWORK ERROR!\n'
      '📍 Endpoint: $endpoint\n'
      '⚠️ Error: $error',
      name: _tag,
    );
    print('═══════════════════════════════════════════════════════════');
    print('🔌 NETWORK ERROR - API CALL નથી થઈ શકી!');
    print('📍 Endpoint: $endpoint');
    print('⚠️ Error: $error');
    print('═══════════════════════════════════════════════════════════');
  }
}
