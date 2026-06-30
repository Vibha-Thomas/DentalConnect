import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/features/dentist/models/dentist_profile.dart';
import 'package:dentconnect_app/features/dentist/repositories/dentist_repository.dart';

class DentistProfileNotifier extends StateNotifier<AsyncValue<DentistProfile?>> {
  final DentistRepository _repository;
  Timer? _debounceTimer;
  Map<String, dynamic> _draftData = {};

  DentistProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final profile = await _repository.getMyProfile();
      state = AsyncValue.data(profile);
      _draftData = profile.toJson();
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

  // Get current draft data
  Map<String, dynamic> get draft => _draftData;

  // Update a single field in the local draft and trigger debounced autosave
  void updateDraftField(String key, dynamic value) {
    _draftData[key] = value;
    
    // Trigger debounced save
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      autosave();
    });
  }

  // Trigger immediate autosave
  Future<void> autosave() async {
    final currentProfile = state.value;
    final isNew = currentProfile == null;
    
    try {
      final profile = isNew
          ? await _repository.createProfile(_draftData)
          : await _repository.updateProfile(_draftData);
      
      // Update state without triggering full UI reloading loaders
      state = AsyncValue.data(profile);
    } catch (e) {
      // For autosave we don't block the screen with full error pages, 
      // but we log it to console or show offline retries.
      print("Autosave failed: $e");
    }
  }

  // Manually save and step forward
  Future<void> saveAndStep(int step) async {
    _draftData['onboardingStep'] = step;
    await _repository.saveOnboardingStep(step);
    await autosave();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final dentistProfileNotifierProvider =
    StateNotifierProvider<DentistProfileNotifier, AsyncValue<DentistProfile?>>(
  (ref) {
    final repository = ref.watch(dentistRepositoryProvider);
    return DentistProfileNotifier(repository);
  },
);
