class User {
  final String? id;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert User to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map (useful for database retrieval)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString(),
      username: map['username'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}