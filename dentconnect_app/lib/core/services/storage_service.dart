import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dentconnect_app/core/constants/app_constants.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveUserInfo({
    required String userId,
    required String role,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.userRoleKey, role);
    if (displayName != null) {
      await prefs.setString('display_name', displayName);
    }
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('display_name');
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
