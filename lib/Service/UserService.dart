import 'dart:convert';
import 'package:health_management/Connection/Neo4jConnection.dart';
import 'package:health_management/model/user.dart';

class UserService {
  final Neo4jConnectionHelper _connectionHelper = Neo4jConnectionHelper();

  // Create a new user
  Future<User> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    // Simple password hashing (in production, use a robust hashing method)
    final passwordHash = _hashPassword(password);

    final user = User(
      username: username,
      email: email,
      passwordHash: passwordHash,
    );

    final cypherQuery = '''
      CREATE (u:User {
        username: \$username,
        email: \$email,
        passwordHash: \$passwordHash,
        createdAt: \$createdAt
      })
      RETURN ID(u) as id, u.username as username, u.email as email, 
             u.passwordHash as passwordHash, u.createdAt as createdAt
    ''';

    try {
      final result = await _connectionHelper.executeQuery(
        cypherQuery: cypherQuery,
        parameters: {
          ...user.toMap(),
        },
      );

      if (result != null && result.isNotEmpty) {
        return User.fromMap(result[0]);
      }

      throw Exception('User creation failed');
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Find user by username
  Future<User?> findUserByUsername(String username) async {
    final cypherQuery = '''
      MATCH (u:User {username: \$username})
      RETURN ID(u) as id, u.username as username, u.email as email, 
             u.passwordHash as passwordHash, u.createdAt as createdAt
    ''';

    try {
      final result = await _connectionHelper.executeQuery(
        cypherQuery: cypherQuery,
        parameters: {'username': username},
      );

      if (result != null && result.isNotEmpty) {
        return User.fromMap(result[0]);
      }

      return null;
    } catch (e) {
      print('Error finding user: $e');
      rethrow;
    }
  }

  // Authenticate user
  Future<User?> authenticateUser({
    required String username,
    required String password,
  }) async {
    final user = await findUserByUsername(username);
    
    if (user == null) return null;

    // Verify password (implement proper password verification)
    if (_verifyPassword(password, user.passwordHash)) {
      return user;
    }

    return null;
  }

  // Update user
  Future<User> updateUser({
    required String userId,
    String? newUsername,
    String? newEmail,
  }) async {
    final updateParams = <String, dynamic>{};
    if (newUsername != null) updateParams['username'] = newUsername;
    if (newEmail != null) updateParams['email'] = newEmail;

    final cypherQuery = '''
      MATCH (u:User)
      WHERE ID(u) = \$userId
      SET ${updateParams.keys.map((key) => 'u.$key = \$$key').join(', ')}
      RETURN ID(u) as id, u.username as username, u.email as email, 
             u.passwordHash as passwordHash, u.createdAt as createdAt
    ''';

    try {
      final result = await _connectionHelper.executeQuery(
        cypherQuery: cypherQuery,
        parameters: {
          'userId': int.parse(userId),
          ...updateParams,
        },
      );

      if (result != null && result.isNotEmpty) {
        return User.fromMap(result[0]);
      }

      throw Exception('User update failed');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    final cypherQuery = '''
      MATCH (u:User)
      WHERE ID(u) = \$userId
      DELETE u
    ''';

    try {
      await _connectionHelper.executeQuery(
        cypherQuery: cypherQuery,
        parameters: {'userId': int.parse(userId)},
      );
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Simple password hashing (IMPORTANT: use a robust method in production)
  String _hashPassword(String password) {
    // WARNING: This is NOT secure. Use a proper hashing library like 'crypto'
    return base64Encode(utf8.encode(password));
  }

  // Simple password verification (IMPORTANT: use a robust method in production)
  bool _verifyPassword(String inputPassword, String storedHash) {
    // WARNING: This is NOT secure. Use proper password verification
    return base64Encode(utf8.encode(inputPassword)) == storedHash;
  }
}
