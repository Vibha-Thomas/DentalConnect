import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/core/network/api_client.dart';
import 'package:dentconnect_app/features/dentist/models/dentist_profile.dart';

class DentistRepository {
  final Dio _dio;

  DentistRepository(this._dio);

  Future<DentistProfile> getMyProfile() async {
    final response = await _dio.get('/dentists/me');
    final data = response.data['data'] as Map<String, dynamic>;
    return DentistProfile.fromJson(data);
  }

  Future<DentistProfile> createProfile(Map<String, dynamic> data) async {
    final response = await _dio.post('/dentists/me', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return DentistProfile.fromJson(responseData);
  }

  Future<DentistProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/dentists/me', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return DentistProfile.fromJson(responseData);
  }

  Future<EducationModel> addEducation(Map<String, dynamic> data) async {
    final response = await _dio.post('/dentists/me/education', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return EducationModel.fromJson(responseData);
  }

  Future<void> deleteEducation(String id) async {
    await _dio.delete('/dentists/me/education/$id');
  }

  Future<ExperienceModel> addExperience(Map<String, dynamic> data) async {
    final response = await _dio.post('/dentists/me/experience', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return ExperienceModel.fromJson(responseData);
  }

  Future<void> deleteExperience(String id) async {
    await _dio.delete('/dentists/me/experience/$id');
  }

  Future<String> uploadResume(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      '/storage/resume',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return response.data['data']['url'] as String? ?? '';
  }
}

final dentistRepositoryProvider = Provider<DentistRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DentistRepository(dio);
});
