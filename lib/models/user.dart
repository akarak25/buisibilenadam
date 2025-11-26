/// User model compatible with elcizgisi.com backend
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String provider;
  final String? googleId;
  final bool emailVerified;
  final String? image;
  final bool isPremium;
  final DateTime? premiumPurchaseDate;
  final int? age;
  final DateTime? dateOfBirth;
  final String? profession;
  final Gender? gender;
  final bool hasCompletedOnboarding;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.provider = 'local',
    this.googleId,
    this.emailVerified = false,
    this.image,
    this.isPremium = false,
    this.premiumPurchaseDate,
    this.age,
    this.dateOfBirth,
    this.profession,
    this.gender,
    this.hasCompletedOnboarding = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      provider: json['provider'] ?? 'local',
      googleId: json['googleId'],
      emailVerified: json['emailVerified'] ?? false,
      image: json['image'],
      isPremium: json['isPremium'] ?? false,
      premiumPurchaseDate: json['premiumPurchaseDate'] != null
          ? DateTime.parse(json['premiumPurchaseDate'])
          : null,
      age: json['age'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      profession: json['profession'],
      gender: json['gender'] != null ? _parseGender(json['gender']) : null,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'provider': provider,
      'googleId': googleId,
      'emailVerified': emailVerified,
      'image': image,
      'isPremium': isPremium,
      'premiumPurchaseDate': premiumPurchaseDate?.toIso8601String(),
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profession': profession,
      'gender': gender?.value,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? provider,
    String? googleId,
    bool? emailVerified,
    String? image,
    bool? isPremium,
    DateTime? premiumPurchaseDate,
    int? age,
    DateTime? dateOfBirth,
    String? profession,
    Gender? gender,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      googleId: googleId ?? this.googleId,
      emailVerified: emailVerified ?? this.emailVerified,
      image: image ?? this.image,
      isPremium: isPremium ?? this.isPremium,
      premiumPurchaseDate: premiumPurchaseDate ?? this.premiumPurchaseDate,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Gender? _parseGender(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return null;
    }
  }
}

enum Gender {
  male('male'),
  female('female'),
  other('other');

  final String value;
  const Gender(this.value);
}
