class Activity {
  final int? id;
  final int? userId;
  final String? username;
  final String description;
  final DateTime? createdAt;

  Activity({
    this.id,
    this.userId,
    this.username,
    required this.description,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }
}

