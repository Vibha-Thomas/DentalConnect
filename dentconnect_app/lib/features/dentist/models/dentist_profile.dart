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

class DocumentSummaryModel {
  final String id;
  final String type;
  final String name;
  final String? mimeType;
  final int? sizeBytes;
  final int versionNumber;
  final bool currentVersion;
  final bool approvedVersion;
  final String verificationStatus;

  const DocumentSummaryModel({
    required this.id,
    required this.type,
    required this.name,
    this.mimeType,
    this.sizeBytes,
    required this.versionNumber,
    required this.currentVersion,
    required this.approvedVersion,
    required this.verificationStatus,
  });

  factory DocumentSummaryModel.fromJson(Map<String, dynamic> json) =>
      DocumentSummaryModel(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        name: json['name'] as String? ?? '',
        mimeType: json['mimeType'] as String?,
        sizeBytes: json['sizeBytes'] as int?,
        versionNumber: json['versionNumber'] as int? ?? 1,
        currentVersion: json['currentVersion'] as bool? ?? true,
        approvedVersion: json['approvedVersion'] as bool? ?? false,
        verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
      );
}

class DentistProfile {
  final String id;
  final String? userId;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? phone;
  final String? photoUrl;
  final String? bio;

  // Address
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  // Professional
  final String? regNumber;
  final String? regCouncil;
  final String? regValidUntil;
  final bool regVerified;
  final String? degree;
  final String? university;
  final int? graduationYear;
  final String? internshipHospital;
  final int experienceYears;
  final int? expectedSalary;
  final int? salaryMin;
  final int? salaryMax;

  // Preferences
  final String? availability;
  final String? employmentPreference;
  final List<String> preferredCities;
  final List<String> languages;

  // Association collections
  final List<SkillModel> skills;
  final List<EducationModel> education;
  final List<ExperienceModel> experiences;
  final List<DocumentSummaryModel> documents;

  // Onboarding & Scoring
  final int onboardingStep;
  final bool onboardingCompleted;
  final int profileCompletionScore;
  final int minimumCompletionForApplication;
  final bool canApplyToJobs;
  final String verificationStatus;

  const DentistProfile({
    required this.id,
    this.userId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.phone,
    this.photoUrl,
    this.bio,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.regNumber,
    this.regCouncil,
    this.regValidUntil,
    required this.regVerified,
    this.degree,
    this.university,
    this.graduationYear,
    this.internshipHospital,
    required this.experienceYears,
    this.expectedSalary,
    this.salaryMin,
    this.salaryMax,
    this.availability,
    this.employmentPreference,
    required this.preferredCities,
    required this.languages,
    required this.skills,
    required this.education,
    required this.experiences,
    required this.documents,
    required this.onboardingStep,
    required this.onboardingCompleted,
    required this.profileCompletionScore,
    required this.minimumCompletionForApplication,
    required this.canApplyToJobs,
    required this.verificationStatus,
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
      fullName: json['fullName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pinCode: json['pinCode'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      regNumber: json['regNumber'] as String?,
      regCouncil: json['regCouncil'] as String?,
      regValidUntil: json['regValidUntil'] as String?,
      regVerified: json['regVerified'] as bool? ?? false,
      degree: json['degree'] as String?,
      university: json['university'] as String?,
      graduationYear: json['graduationYear'] as int?,
      internshipHospital: json['internshipHospital'] as String?,
      experienceYears: json['experienceYears'] as int? ?? 0,
      expectedSalary: json['expectedSalary'] as int?,
      salaryMin: json['salaryMin'] as int?,
      salaryMax: json['salaryMax'] as int?,
      availability: json['availability'] as String?,
      employmentPreference: json['employmentPreference'] as String?,
      preferredCities: parseStringList(json['preferredCities']),
      languages: parseStringList(json['languages']),
      skills: parseList<SkillModel>(json['skills'], SkillModel.fromJson),
      education: parseList<EducationModel>(json['education'], EducationModel.fromJson),
      experiences: parseList<ExperienceModel>(json['experience'], ExperienceModel.fromJson), // mapped to backend experience field
      documents: parseList<DocumentSummaryModel>(json['documents'], DocumentSummaryModel.fromJson),
      onboardingStep: json['onboardingStep'] as int? ?? 0,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      profileCompletionScore: json['profileCompletionScore'] as int? ?? 0,
      minimumCompletionForApplication: json['minimumCompletionForApplication'] as int? ?? 80,
      canApplyToJobs: json['canApplyToJobs'] as bool? ?? false,
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'phone': phone,
      'bio': bio,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'regNumber': regNumber,
      'regCouncil': regCouncil,
      'regValidUntil': regValidUntil,
      'degree': degree,
      'university': university,
      'graduationYear': graduationYear,
      'internshipHospital': internshipHospital,
      'experienceYears': experienceYears,
      'expectedSalary': expectedSalary,
      'availability': availability,
      'employmentPreference': employmentPreference,
      'preferredCities': preferredCities,
      'languages': languages,
      'skillIds': skills.map((s) => s.id).toList(),
      'onboardingStep': onboardingStep,
    };
  }
}
