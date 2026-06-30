import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dentconnect_app/features/dentist/providers/dentist_provider.dart';

class DentistProfileScreen extends ConsumerWidget {
  const DentistProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(dentistProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/dentist/onboarding'),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not initialized.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: profile.photoUrl != null
                              ? NetworkImage(profile.photoUrl!)
                              : null,
                          child: profile.photoUrl == null
                              ? Text(
                                  profile.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.degree ?? 'Degree Pending',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(
                            profile.verificationStatus,
                            style: TextStyle(
                              color: profile.verificationStatus == 'VERIFIED'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                          backgroundColor: profile.verificationStatus == 'VERIFIED'
                              ? Colors.green[100]
                              : Colors.orange[100],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Info section
                _buildSectionCard(
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow('Gender', profile.gender ?? 'Not Specified'),
                    _buildInfoRow('Nationality', profile.nationality ?? 'Not Specified'),
                    _buildInfoRow('Phone', profile.phone ?? 'Not Specified'),
                    _buildInfoRow('Birth Date', profile.dateOfBirth ?? 'Not Specified'),
                  ],
                ),
                const SizedBox(height: 16),

                // Location pref section
                _buildSectionCard(
                  title: 'Professional Details',
                  children: [
                    _buildInfoRow('Reg Council Number', profile.regNumber ?? 'Not Specified'),
                    _buildInfoRow('Years of Practice', '${profile.experienceYears} Years'),
                    _buildInfoRow('Prefer Preference', profile.employmentPreference ?? 'Not Specified'),
                    _buildInfoRow('Internship Hospital', profile.internshipHospital ?? 'Not Specified'),
                  ],
                ),
                const SizedBox(height: 16),

                // Skills section
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clinical Skills',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        if (profile.skills.isEmpty)
                          const Text('No skills selected yet.')
                        else
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: profile.skills
                                .map((skill) => Chip(label: Text(skill.name)))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
