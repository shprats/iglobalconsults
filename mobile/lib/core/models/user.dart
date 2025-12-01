/// User Model
/// Represents a user in the system

class User {
  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  bool get isDoctor => role == 'requesting_doctor';
  bool get isVolunteer => role == 'volunteer_physician';
  bool get isAdmin => role == 'site_admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

