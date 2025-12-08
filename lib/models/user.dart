class User {
  final int? id;
  final String username;
  final String? password;
  final String role;
  final String? name;
  final String? email;
  final String? unp;
  final String? activityType;

  User({
    this.id,
    required this.username,
    this.password,
    required this.role,
    this.name,
    this.email,
    this.unp,
    this.activityType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      unp: json['unp'],
      activityType: json['activityType'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'role': role,
    };
    if (id != null) data['id'] = id;
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (unp != null) data['unp'] = unp;
    if (activityType != null) data['activityType'] = activityType;
    return data;
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? name,
    String? email,
    String? unp,
    String? activityType,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      unp: unp ?? this.unp,
      activityType: activityType ?? this.activityType,
    );
  }
}

