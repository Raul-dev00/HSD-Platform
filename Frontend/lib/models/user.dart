import 'skill.dart';

class User {
  final int id;
  final String name;
  final String email;
  final int? yearLevel;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? bio;
  final int? universityId;
  final String? universityName;
  final int? departmentId;
  final String? departmentName;
  final List<Skill> skills;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.yearLevel,
    this.githubUrl,
    this.linkedinUrl,
    this.bio,
    this.universityId,
    this.universityName,
    this.departmentId,
    this.departmentName,
    this.skills = const [],
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        yearLevel: json['yearLevel'],
        githubUrl: json['githubUrl'],
        linkedinUrl: json['linkedinUrl'],
        bio: json['bio'],
        universityId: json['universityId'],
        universityName: json['universityName'],
        departmentId: json['departmentId'],
        departmentName: json['departmentName'],
        skills: (json['skills'] as List<dynamic>? ?? [])
            .map((s) => Skill.fromJson(s))
            .toList(),
        createdAt: json['createdAt'],
      );
}
