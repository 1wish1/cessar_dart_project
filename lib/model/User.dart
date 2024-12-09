class User {
  final String username;
  late String password;
  final String email;
  final int id;

  User({
    required this.username,
    required this.password,
    required this.email, 
    required this.id,
  });

  // Factory method to create a User from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      password: map['name'] as String,
      email: map['email'] as String,
      id: map['id'] as int
    );
  }

  @override
  String toString() {
    return 'User(username: $username, password: $password, email: $email, id: $id)';
  }
}
