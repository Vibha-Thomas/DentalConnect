class ProfileCompletionBreakdown {
  final int personal;
  final int professional;
  final int skills;
  final int documents;
  final int preferences;
  final int total;
  final int minimumRequired;
  final bool canApplyToJobs;

  ProfileCompletionBreakdown({
    required this.personal,
    required this.professional,
    required this.skills,
    required this.documents,
    required this.preferences,
    required this.total,
    required this.minimumRequired,
    required this.canApplyToJobs,
  });

  factory ProfileCompletionBreakdown.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionBreakdown(
      personal: json['personal'] as int? ?? 0,
      professional: json['professional'] as int? ?? 0,
      skills: json['skills'] as int? ?? 0,
      documents: json['documents'] as int? ?? 0,
      preferences: json['preferences'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      minimumRequired: json['minimumRequired'] as int? ?? 80,
      canApplyToJobs: json['canApplyToJobs'] as bool? ?? false,
    );
  }
}
