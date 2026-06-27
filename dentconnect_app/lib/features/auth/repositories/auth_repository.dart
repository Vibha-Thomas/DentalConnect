import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/core/network/api_client.dart';
import 'package:dentconnect_app/features/auth/models/auth_response.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> loginWithFirebaseToken(
    String token, {
    String? role,
    String? displayName,
    String? phone,
  }) async {
    final body = <String, dynamic>{'firebaseToken': token};
    if (role != null) body['role'] = role;
    if (displayName != null) body['displayName'] = displayName;
    if (phone != null) body['phone'] = phone;

    final response = await _dio.post('/auth/login', data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Ignore logout errors — clear local state regardless
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
