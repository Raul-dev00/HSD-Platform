class Skill {
  final int id;
  final String name;
  final String category;

  Skill({required this.id, required this.name, required this.category});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'],
        name: json['name'],
        category: json['category'] ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'category': category};
}
