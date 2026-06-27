class SkillModel {
  final String id;
  final String name;
  final String? category;

  const SkillModel({
    required this.id,
    required this.name,
    this.category,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) => SkillModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (category != null) 'category': category,
      };
}

class EducationModel {
  final String id;
  final String? dentistId;
  final String degree;
  final String institution;
  final int? startYear;
  final int? endYear;
  final String? grade;

  const EducationModel({
    required this.id,
    this.dentistId,
    required this.degree,
    required this.institution,
    this.startYear,
    this.endYear,
    this.grade,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) => EducationModel(
        id: json['id'] as String? ?? '',
        dentistId: json['dentistId'] as String?,
        degree: json['degree'] as String? ?? '',
        institution: json['institution'] as String? ?? '',
        startYear: json['startYear'] as int?,
        endYear: json['endYear'] as int?,
        grade: json['grade'] as String?,
      );
}

class ExperienceModel {
  final String id;
  final String title;
  final String organization;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  const ExperienceModel({
    required this.id,
    required this.title,
    required this.organization,
    this.location,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      ExperienceModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        organization: json['organization'] as String? ?? '',
        location: json['location'] as String?,
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        isCurrent: json['isCurrent'] as bool? ?? false,
        description: json['description'] as String?,
      );
}

class DentistProfile {
  final String id;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final String? bio;
  final String? regNumber;
  final String? regCouncil;
  final int? experienceYears;
  final String? gender;
  final double? salaryMin;
  final double? salaryMax;
  final String? availability;
  final List<String> preferredCities;
  final List<String> languages;
  final List<SkillModel> skills;
  final List<EducationModel> education;
  final List<ExperienceModel> experiences;
  final String? resumeUrl;

  const DentistProfile({
    required this.id,
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.bio,
    this.regNumber,
    this.regCouncil,
    this.experienceYears,
    this.gender,
    this.salaryMin,
    this.salaryMax,
    this.availability,
    required this.preferredCities,
    required this.languages,
    required this.skills,
    required this.education,
    required this.experiences,
    this.resumeUrl,
  });

  factory DentistProfile.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String> parseStringList(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>).map((e) => e.toString()).toList();
    }

    return DentistProfile(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      regNumber: json['regNumber'] as String?,
      regCouncil: json['regCouncil'] as String?,
      experienceYears: json['experienceYears'] as int?,
      gender: json['gender'] as String?,
      salaryMin: (json['salaryMin'] as num?)?.toDouble(),
      salaryMax: (json['salaryMax'] as num?)?.toDouble(),
      availability: json['availability'] as String?,
      preferredCities: parseStringList(json['preferredCities']),
      languages: parseStringList(json['languages']),
      skills: parseList<SkillModel>(json['skills'], SkillModel.fromJson),
      education:
          parseList<EducationModel>(json['education'], EducationModel.fromJson),
      experiences: parseList<ExperienceModel>(
          json['experiences'], ExperienceModel.fromJson),
      resumeUrl: json['resumeUrl'] as String?,
    );
  }
}
