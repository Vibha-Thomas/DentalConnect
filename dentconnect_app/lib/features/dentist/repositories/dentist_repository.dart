import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/core/network/api_client.dart';
import 'package:dentconnect_app/features/dentist/models/dentist_profile.dart';
import 'package:dentconnect_app/features/dentist/models/profile_completion.dart';

class DentistRepository {
  final Dio _dio;

  DentistRepository(this._dio);

  Future<bool> checkProfileExists() async {
    try {
      final response = await _dio.get('/dentists/me/exists');
      return response.data['data']['exists'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<DentistProfile> getMyProfile() async {
    final response = await _dio.get('/dentists/me');
    return DentistProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DentistProfile> createProfile(Map<String, dynamic> data) async {
    final response = await _dio.post('/dentists/me', data: data);
    return DentistProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DentistProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/dentists/me', data: data);
    return DentistProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<ProfileCompletionBreakdown> getCompletionDetails() async {
    final response = await _dio.get('/dentists/me/completion');
    return ProfileCompletionBreakdown.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> saveOnboardingStep(int step) async {
    await _dio.put('/dentists/me/onboarding-step', data: {'step': step});
  }

  Future<String> uploadProfilePhoto(File file) async {
    final filename = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: filename),
    });
    final response = await _dio.post('/dentists/me/photo', data: formData);
    return response.data['data']['storagePath'] as String;
  }

  Future<void> uploadDocument(File file, String docType, {String? customName}) async {
    final filename = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: filename),
      'type': docType,
      if (customName != null) 'name': customName,
    });
    await _dio.post('/dentists/me/documents', data: formData);
  }

  Future<String> getDocumentSignedUrl(String documentId) async {
    final response = await _dio.get('/dentists/me/documents/$documentId/url');
    return response.data['data']['url'] as String;
  }

  Future<void> deleteDocument(String documentId) async {
    await _dio.delete('/dentists/me/documents/$documentId');
  }

  Future<List<SkillModel>> getSkillsList() async {
    final response = await _dio.get('/skills');
    final list = response.data['data'] as List?;
    if (list == null) return [];
    return list.map((e) => SkillModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final dentistRepositoryProvider = Provider<DentistRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DentistRepository(dio);
});
