import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/utils.dart';
import '../config/app_config.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Dio get _dio => AppConfig.dio;
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  // Custom Backend doesn't have a built-in auth state stream, so we manage our own
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  /// Stream of auth state changes. Emits the current user map or null.
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await _dio.post<dynamic>('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _persistAuthResponse(data);
      _authStateController.add(data['user'] as Map<String, dynamic>?);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await _dio.post<dynamic>('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _persistAuthResponse(data);
      _authStateController.add(data['user'] as Map<String, dynamic>?);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _dio.post<dynamic>('/auth/forgot-password', data: {'email': email});
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _secureStorage.delete('auth_token');
      _authStateController.add(null);
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final tokenResult = await _secureStorage.read('auth_token');
      final token = tokenResult.fold((_) => null, (value) => value);
      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await _dio.get<dynamic>('/auth/me');
      return response.data as Map<String, dynamic>;
    });
  }

  FutureEither<Map<String, dynamic>?> updateProfile({
    required String name,
    File? photo,
  }) async {
    return runTask(() async {
      final formData = FormData.fromMap({
        'name': name,
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: photo.uri.pathSegments.isNotEmpty
                ? photo.uri.pathSegments.last
                : 'profile-photo.jpg',
          ),
      });

      final response = await _dio.patch<dynamic>(
        '/auth/profile',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      final data = response.data as Map<String, dynamic>;
      _authStateController.add(data['user'] as Map<String, dynamic>?);
      return data;
    }, requiresNetwork: true);
  }

  Future<void> _persistAuthResponse(Map<String, dynamic> data) async {
    final token = data['accessToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write('auth_token', token);
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
