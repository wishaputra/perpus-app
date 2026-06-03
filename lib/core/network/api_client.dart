import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;
  
  // Konfigurasi apakah menggunakan data tiruan (Mock Data) untuk demo
  static const bool useMock = true;
  
  // Base URL default ke RESTful API Golang
  static const String baseUrl = 'http://localhost:8080/api/v1';

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Tangani global error di sini (misal: redirect ke login jika 401)
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
