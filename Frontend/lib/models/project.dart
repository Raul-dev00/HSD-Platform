class Project {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String? createdAt;
  final int ownerId;
  final String ownerName;
  final int memberCount;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.createdAt,
    required this.ownerId,
    required this.ownerName,
    this.memberCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        status: json['status'] ?? 'OPEN',
        createdAt: json['createdAt'],
        ownerId: json['ownerId'],
        ownerName: json['ownerName'] ?? '',
        memberCount: json['memberCount'] ?? 0,
      );

  String get statusLabel {
    switch (status) {
      case 'OPEN':
        return 'Açık';
      case 'IN_PROGRESS':
        return 'Devam Ediyor';
      case 'COMPLETED':
        return 'Tamamlandı';
      case 'CANCELLED':
        return 'İptal';
      default:
        return status;
    }
  }
}

class ProjectMember {
  final int id;
  final int projectId;
  final String? projectName;
  final int userId;
  final String userName;
  final String userEmail;
  final String? role;
  final String memberStatus;
  final String? appliedAt;
  final String? respondedAt;

  ProjectMember({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.role,
    required this.memberStatus,
    this.appliedAt,
    this.respondedAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) => ProjectMember(
        id: json['id'],
        projectId: json['projectId'],
        projectName: json['projectName'],
        userId: json['userId'],
        userName: json['userName'] ?? '',
        userEmail: json['userEmail'] ?? '',
        role: json['role'],
        memberStatus: json['memberStatus'] ?? 'PENDING',
        appliedAt: json['appliedAt'],
        respondedAt: json['respondedAt'],
      );
}
