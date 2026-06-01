class UserModel {
  final String token;
  final String userType;
  final String uniqueId;

  UserModel({
    required this.token,
    required this.userType,
    required this.uniqueId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token:    json['token']     ?? '',
      userType: json['user_type'] ?? '',
      uniqueId: json['unique_id'] ?? '',
    );
  }
}

class ProfileModel {
  final String uniqueId;
  final String userType;
  final String firstName;
  final String middleName;
  final String lastName;
  final String nationalId;
  final String nationality;
  final String email;
  final String phoneNumber;
  final String? profilePhoto;
  final String companyName;
  final String? legalEntityType;
  final String? commercialRegistry;
  final String? taxId;
  final String? address;
  final String? website;
  final String? managerName;
  final String? jobStatus;
  final List<CareerModel> careerHistory;
  final List<EducationModel> educationHistory;
  final List<CertificateModel> certificates;
  final List<SkillModel> skills;

  ProfileModel({
    required this.uniqueId,
    required this.userType,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.nationalId,
    required this.nationality,
    required this.email,
    required this.phoneNumber,
    this.profilePhoto,
    required this.companyName,
    this.legalEntityType,
    this.commercialRegistry,
    this.taxId,
    this.address,
    this.website,
    this.managerName,
    this.jobStatus,
    required this.careerHistory,
    required this.educationHistory,
    required this.certificates,
    required this.skills,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uniqueId:     json['unique_id']   ?? '',
      userType:     json['user_type']   ?? '',
      firstName:    json['first_name']  ?? '',
      middleName:   json['middle_name'] ?? '',
      lastName:     json['last_name']   ?? '',
      nationalId:   json['national_id'] ?? '',
      nationality:  json['nationality'] ?? '',
      email:        json['email']       ?? '',
      phoneNumber:  json['phone_number'] ?? '',
      profilePhoto: json['profile_photo'],
      companyName:        json['company_name']        ?? '',
      legalEntityType:    json['legal_entity_type'],
      commercialRegistry: json['commercial_registry'],
      taxId:              json['tax_id'],
      address:            json['address'],
      website:            json['website'],
      managerName:        json['manager_name'],
      jobStatus:          json['job_status'],
      careerHistory: (json['career_history'] as List<dynamic>? ?? [])
          .map((e) => CareerModel.fromJson(e))
          .toList(),
      educationHistory: (json['education_history'] as List<dynamic>? ?? [])
          .map((e) => EducationModel.fromJson(e))
          .toList(),
      certificates: (json['certificates'] as List<dynamic>? ?? [])
          .map((e) => CertificateModel.fromJson(e))
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => SkillModel.fromJson(e))
          .toList(),
    );
  }

  String get fullName => '$firstName $middleName $lastName'.trim().replaceAll(RegExp(r'\s+'), ' ');
}

class CareerModel {
  final int id;
  final String companyName;
  final String jobTitle;
  final String startDate;
  final String? endDate;
  final String? description;
  final bool addedByCompany;

  CareerModel({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.startDate,
    this.endDate,
    this.description,
    this.addedByCompany = false,
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id:             json['id']               ?? 0,
      companyName:    json['company_name']      ?? '',
      jobTitle:       json['job_title']         ?? '',
      startDate:      json['start_date']        ?? '',
      endDate:        json['end_date'],
      description:    json['description'],
      addedByCompany: json['added_by_company']  ?? false,
    );
  }
}

class EducationModel {
  final int id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String? endDate;

  EducationModel({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id:           json['id']             ?? 0,
      institution:  json['institution']    ?? '',
      degree:       json['degree']         ?? '',
      fieldOfStudy: json['field_of_study'] ?? '',
      startDate:    json['start_date']     ?? '',
      endDate:      json['end_date'],
    );
  }
}

class CertificateModel {
  final int id;
  final String title;
  final String major;
  final String issueDate;
  final String certificateHash;
  final String? image;
  final bool isVerified;
  final String status;
  final String issuerName;

  CertificateModel({
    required this.id,
    required this.title,
    required this.major,
    required this.issueDate,
    required this.certificateHash,
    this.image,
    required this.isVerified,
    required this.status,
    required this.issuerName,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id:              json['id']               ?? 0,
      title:           json['title']            ?? '',
      major:           json['major']            ?? '',
      issueDate:       json['issue_date']        ?? '',
      certificateHash: json['certificate_hash'] ?? '',
      image:           json['image'],
      isVerified:      json['is_verified']      ?? false,
      status:          json['status']           ?? '',
      issuerName:      json['issuer_name']      ?? '',
    );
  }
}

class SkillModel {
  final int id;
  final String skillName;
  final String medalType;
  final String progressLevel;
  final int score;
  final String? aiFeedback;
  final String? skillImage;

  SkillModel({
    required this.id,
    required this.skillName,
    required this.medalType,
    required this.progressLevel,
    required this.score,
    this.aiFeedback,
    this.skillImage,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id:            json['id']             ?? 0,
      skillName:     json['skill_name']     ?? '',
      medalType:     json['medal_type']     ?? '',
      progressLevel: json['progress_level'] ?? '',
      score:         json['score']          ?? 0,
      aiFeedback:    json['ai_feedback'],
      skillImage:    json['skill_image'],
    );
  }
}

class NotificationModel {
  final int id;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['id']         ?? 0,
      message:   json['message']    ?? '',
      isRead:    json['is_read']    ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class CourseModel {
  final int id;
  final String name;
  final String description;
  final String startDate;
  final String? endDate;
  final bool isIssued;
  final int participantsCount;

  CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.isIssued,
    required this.participantsCount,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id:                json['id']                ?? 0,
      name:              json['name']              ?? '',
      description:       json['description']       ?? '',
      startDate:         json['start_date']         ?? '',
      endDate:           json['end_date'],
      isIssued:          json['is_issued']          ?? false,
      participantsCount: json['participants_count'] ?? 0,
    );
  }
}
