import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/features/dentist/models/dentist_profile.dart';
import 'package:dentconnect_app/features/dentist/repositories/dentist_repository.dart';

class DentistProfileNotifier
    extends StateNotifier<AsyncValue<DentistProfile?>> {
  final DentistRepository _repository;

  DentistProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final profile = await _repository.getMyProfile();
      state = AsyncValue.data(profile);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          e.response?.data?['message'] ?? 'Failed to load profile',
          StackTrace.current,
        );
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> refresh() => _init();

  Future<void> createOrUpdateProfile(
    Map<String, dynamic> data,
    bool isNew,
  ) async {
    state = const AsyncValue.loading();
    try {
      final profile = isNew
          ? await _repository.createProfile(data)
          : await _repository.updateProfile(data);
      state = AsyncValue.data(profile);
    } on DioException catch (e) {
      state = AsyncValue.error(
        e.response?.data?['message'] ?? 'Failed to save profile',
        StackTrace.current,
      );
      rethrow;
    }
  }

  Future<void> addEducation(Map<String, dynamic> data) async {
    try {
      await _repository.addEducation(data);
      await _init();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to add education';
    }
  }

  Future<void> addExperience(Map<String, dynamic> data) async {
    try {
      await _repository.addExperience(data);
      await _init();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to add experience';
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await _repository.deleteEducation(id);
      await _init();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to delete education';
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _repository.deleteExperience(id);
      await _init();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to delete experience';
    }
  }
}

final dentistProfileNotifierProvider =
    StateNotifierProvider<DentistProfileNotifier, AsyncValue<DentistProfile?>>(
  (ref) {
    final repository = ref.watch(dentistRepositoryProvider);
    return DentistProfileNotifier(repository);
  },
);
