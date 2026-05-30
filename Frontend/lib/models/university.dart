class University {
  final int id;
  final String name;
  final String? city;
  final int memberCount;

  University({
    required this.id,
    required this.name,
    this.city,
    this.memberCount = 0,
  });

  factory University.fromJson(Map<String, dynamic> json) => University(
        id: json['id'],
        name: json['name'],
        city: json['city'],
        memberCount: json['memberCount'] ?? 0,
      );
}

class Department {
  final int id;
  final String name;
  final int universityId;
  final String? universityName;

  Department({
    required this.id,
    required this.name,
    required this.universityId,
    this.universityName,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'],
        name: json['name'],
        universityId: json['universityId'],
        universityName: json['universityName'],
      );
}
