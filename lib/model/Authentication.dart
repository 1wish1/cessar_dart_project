class Authentication {
  final String token;
  final String createdAt;
  final int userId;
  final int ExpiresIn = 3600; 

  Authentication({required this.token, required this.createdAt,required this.userId, ExpiresIn});

  // Factory method to create an instance from JSON data
  factory Authentication.fromJson(Map<String, dynamic> json) {
    return Authentication(
      token: json['token'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      ExpiresIn: json['ExpiresIn'],
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'createdAt': createdAt,
      'userId': userId,
      'ExpiresIn': ExpiresIn,
    };
  }
}
