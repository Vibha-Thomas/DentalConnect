import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dentconnect_app/features/dentist/models/dentist_profile.dart';
import 'package:dentconnect_app/features/dentist/providers/dentist_provider.dart';
import 'package:dentconnect_app/features/dentist/repositories/dentist_repository.dart';

class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({super.key});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  int _currentStep = 0;
  bool _isSaving = false;
  String? _uploadStatusMessage;

  // Controllers for forms
  final _personalFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _profFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pinController = TextEditingController();

  final _regNumController = TextEditingController();
  final _regCouncilController = TextEditingController();
  final _degreeController = TextEditingController();
  final _universityController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _nationalityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinController.dispose();
    _regNumController.dispose();
    _regCouncilController.dispose();
    _degreeController.dispose();
    _universityController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _syncProfileToControllers(DentistProfile? profile) {
    if (profile == null) return;
    if (_nameController.text.isEmpty) _nameController.text = profile.fullName;
    if (_bioController.text.isEmpty) _bioController.text = profile.bio ?? '';
    if (_nationalityController.text.isEmpty) _nationalityController.text = profile.nationality ?? '';
    if (_phoneController.text.isEmpty) _phoneController.text = profile.phone ?? '';
    
    if (_addressController.text.isEmpty) _addressController.text = profile.address ?? '';
    if (_cityController.text.isEmpty) _cityController.text = profile.city ?? '';
    if (_stateController.text.isEmpty) _stateController.text = profile.state ?? '';
    if (_countryController.text.isEmpty) _countryController.text = profile.country ?? '';
    if (_pinController.text.isEmpty) _pinController.text = profile.pinCode ?? '';

    if (_regNumController.text.isEmpty) _regNumController.text = profile.regNumber ?? '';
    if (_regCouncilController.text.isEmpty) _regCouncilController.text = profile.regCouncil ?? '';
    if (_degreeController.text.isEmpty) _degreeController.text = profile.degree ?? '';
    if (_universityController.text.isEmpty) _universityController.text = profile.university ?? '';
    if (_experienceController.text.isEmpty) {
      _experienceController.text = profile.experienceYears.toString();
    }
  }

  Future<void> _uploadDoc(String docType) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isSaving = true;
        _uploadStatusMessage = "Uploading $docType...";
      });
      try {
        final repo = ref.read(dentistRepositoryProvider);
        await repo.uploadDocument(File(result.files.single.path!), docType);
        ref.invalidate(dentistProfileNotifierProvider);
        setState(() {
          _uploadStatusMessage = "Upload Successful!";
        });
      } catch (err) {
        setState(() {
          _uploadStatusMessage = "Upload failed. Please try again.";
        });
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(dentistProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dentist Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading onboarding: $err')),
        data: (profile) {
          _syncProfileToControllers(profile);
          final score = profile?.profileCompletionScore ?? 0;

          return Column(
            children: [
              // Animated progress indicator header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Completion: $score%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Chip(
                              label: Text('Draft Autosaved', style: TextStyle(fontSize: 12)),
                              backgroundColor: Colors.greenAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: score / 100.0,
                          backgroundColor: Colors.grey[300],
                          color: score >= 80 ? Colors.green : Colors.blue,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Steps Stepper Content
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    onStepContinue: () async {
                      final notifier = ref.read(dentistProfileNotifierProvider.notifier);
                      
                      // Validate and sync before stepping
                      if (_currentStep == 0) {
                        if (!_personalFormKey.currentState!.validate()) return;
                        notifier.updateDraftField('fullName', _nameController.text);
                        notifier.updateDraftField('bio', _bioController.text);
                        notifier.updateDraftField('nationality', _nationalityController.text);
                        notifier.updateDraftField('phone', _phoneController.text);
                      } else if (_currentStep == 1) {
                        if (!_addressFormKey.currentState!.validate()) return;
                        notifier.updateDraftField('address', _addressController.text);
                        notifier.updateDraftField('city', _cityController.text);
                        notifier.updateDraftField('state', _stateController.text);
                        notifier.updateDraftField('country', _countryController.text);
                        notifier.updateDraftField('pinCode', _pinController.text);
                      } else if (_currentStep == 2) {
                        if (!_profFormKey.currentState!.validate()) return;
                        notifier.updateDraftField('regNumber', _regNumController.text);
                        notifier.updateDraftField('regCouncil', _regCouncilController.text);
                        notifier.updateDraftField('degree', _degreeController.text);
                        notifier.updateDraftField('university', _universityController.text);
                        notifier.updateDraftField('experienceYears', int.tryParse(_experienceController.text) ?? 0);
                      }

                      if (_currentStep < 4) {
                        setState(() {
                          _currentStep += 1;
                        });
                        await notifier.saveAndStep(_currentStep);
                      } else {
                        // Finish Onboarding
                        await notifier.saveAndStep(6);
                        context.go('/dentist');
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    steps: [
                      Step(
                        title: const Text('Personal'),
                        isActive: _currentStep >= 0,
                        content: Form(
                          key: _personalFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Full Name *'),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              TextFormField(
                                controller: _bioController,
                                decoration: const InputDecoration(labelText: 'Bio / About Me'),
                              ),
                              TextFormField(
                                controller: _nationalityController,
                                decoration: const InputDecoration(labelText: 'Nationality'),
                              ),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Phone Number'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: const Text('Address'),
                        isActive: _currentStep >= 1,
                        content: Form(
                          key: _addressFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(labelText: 'Street Address'),
                              ),
                              TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(labelText: 'City *'),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              TextFormField(
                                controller: _stateController,
                                decoration: const InputDecoration(labelText: 'State'),
                              ),
                              TextFormField(
                                controller: _countryController,
                                decoration: const InputDecoration(labelText: 'Country'),
                              ),
                              TextFormField(
                                controller: _pinController,
                                decoration: const InputDecoration(labelText: 'Pincode'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: const Text('Professional'),
                        isActive: _currentStep >= 2,
                        content: Form(
                          key: _profFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _regNumController,
                                decoration: const InputDecoration(labelText: 'Dental Council Registration Number *'),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              TextFormField(
                                controller: _regCouncilController,
                                decoration: const InputDecoration(labelText: 'Registration Council'),
                              ),
                              TextFormField(
                                controller: _degreeController,
                                decoration: const InputDecoration(labelText: 'Degree Earned'),
                              ),
                              TextFormField(
                                controller: _universityController,
                                decoration: const InputDecoration(labelText: 'University / College'),
                              ),
                              TextFormField(
                                controller: _experienceController,
                                decoration: const InputDecoration(labelText: 'Years of Experience'),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: const Text('Documents'),
                        isActive: _currentStep >= 3,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Upload Certificates & Licenses',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            if (_uploadStatusMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(_uploadStatusMessage!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Dental License (PDF)'),
                              onPressed: () => _uploadDoc('LICENSE'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Degree Certificate (PDF)'),
                              onPressed: () => _uploadDoc('DEGREE_CERT'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Resume (PDF)'),
                              onPressed: () => _uploadDoc('RESUME'),
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Finish'),
                        isActive: _currentStep >= 4,
                        content: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
                              SizedBox(height: 16),
                              Text(
                                'Onboarding Wizard Complete!',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              Text('Click continue to submit your details and proceed to the Home page.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
