import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/core/constants/app_constants.dart';
import 'package:dentconnect_app/core/services/storage_service.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final storage = StorageService();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await storage.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              return handler.next(error);
            }

            final refreshDio = Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                headers: {'Content-Type': 'application/json'},
              ),
            );

            final response = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['data']['accessToken'] as String?;
            final newRefreshToken = response.data['data']['refreshToken'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              await storage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            }
          } catch (_) {
            await storage.clearAll();
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) => createDio());
