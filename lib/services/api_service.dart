import 'package:dio/dio.dart';
import 'package:tume_ride_passenger/config/app_config.dart';
import 'package:tume_ride_passenger/services/auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    print('🌐 API Base URL: ${AppConfig.apiBaseUrl}');

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add CORS header for web
    _dio.options.headers['Access-Control-Allow-Origin'] = '*';

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getToken();
        print('🔑 Token check for ${options.path}: ${token != null ? 'Present (${token.substring(0, token.length > 20 ? 20 : token.length)}...)' : 'Missing'}');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('✅ Token added to request');
        } else {
          print('❌ No token available - request may fail for protected endpoints');
        }

        print('📡 ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          print('📡 Query params: ${options.queryParameters}');
        }
        if (options.data != null) {
          print('📡 Data: ${options.data}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Response: ${response.statusCode} for ${response.requestOptions.path}');
        if (response.data is Map) {
          print('📦 Response status: ${response.data['status']}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error for ${error.requestOptions.path}: ${error.message}');
        if (error.response != null) {
          print('❌ Response status: ${error.response?.statusCode}');
          print('❌ Response data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));

    _isInitialized = true;
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      await _ensureInitialized();
      print('📡 POST Request: $endpoint');
      print('📡 POST Data: $data');
      final response = await _dio.post(endpoint, data: data);
      print('📡 POST Response Status: ${response.statusCode}');
      print('📡 POST Response Body: ${response.data}');
      return _handleResponse(response);
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      return _handleError(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      await _ensureInitialized();
      print('📡 GET Request: $endpoint');
      print('📡 Query params: $queryParams');
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      print('📡 GET Response Status: ${response.statusCode}');
      print('📡 GET Response Body: ${response.data}');
      return _handleResponse(response);
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      return _handleError(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'status': 'error', 'message': 'Invalid response format'};
    }
    return {
      'status': 'error',
      'message': 'HTTP ${response.statusCode}: ${response.statusMessage}'
    };
  }

  Map<String, dynamic> _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Request failed',
          'code': error.response?.statusCode
        };
      }
      return {
        'status': 'error',
        'message': 'Server error: ${error.response?.statusCode}',
        'code': error.response?.statusCode
      };
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return {'status': 'error', 'message': 'Connection timeout. Please try again.'};
    }

    if (error.type == DioExceptionType.connectionError) {
      return {'status': 'error', 'message': 'No internet connection. Please check your network.'};
    }

    return {
      'status': 'error',
      'message': error.message ?? 'Connection error'
    };
  }
}