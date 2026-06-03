import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<User> login(String username, String password) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username dan password tidak boleh kosong');
      }
      
      final mockUser = UserModel(
        id: 'U001',
        username: username,
        nama: username.toUpperCase() == 'ADMIN' ? 'Administrator' : username,
        role: 'PEGAWAI',
        token: 'mock_jwt_token_for_$username',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', mockUser.token!);
      await prefs.setString('user_id', mockUser.id);
      await prefs.setString('user_username', mockUser.username);
      await prefs.setString('user_nama', mockUser.nama);
      await prefs.setString('user_role', mockUser.role);

      return mockUser;
    } else {
      try {
        final response = await _apiClient.dio.post('/login', data: {
          'username': username,
          'password': password,
        });

        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          final userModel = UserModel.fromJson(data);
          
          final prefs = await SharedPreferences.getInstance();
          if (userModel.token != null) {
            await prefs.setString('jwt_token', userModel.token!);
          }
          await prefs.setString('user_id', userModel.id);
          await prefs.setString('user_username', userModel.username);
          await prefs.setString('user_nama', userModel.nama);
          await prefs.setString('user_role', userModel.role);

          return userModel;
        } else {
          throw Exception(response.data['message'] ?? 'Gagal login');
        }
      } on DioException catch (e) {
        final errorMsg = e.response?.data?['message'] ?? 'Koneksi gagal: ${e.message}';
        throw Exception(errorMsg);
      }
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_nama');
    await prefs.remove('user_role');
  }

  @override
  Future<User?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;

    return User(
      id: prefs.getString('user_id') ?? '',
      username: prefs.getString('user_username') ?? '',
      nama: prefs.getString('user_nama') ?? '',
      role: prefs.getString('user_role') ?? '',
      token: token,
    );
  }
}
