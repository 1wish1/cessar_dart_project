
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_management/Service/TokenService.dart';
import 'package:health_management/di.dart';
import 'package:health_management/model/User.dart';
import 'package:neo4j_http_client/neo4j_http_client.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:health_management/model/User.dart';

import '../Connection/Neo4jConnection.dart';

class UserService with ChangeNotifier{
  // Method to insert a user into the Neo4j database
  final client = Neo4jConnection.getClient();
  TokenService get tokenService => sl<TokenService>();

  
  User? _currentUser;
  bool isLogin = false; 

  User? get currentUser => _currentUser;

  Future<void> insertUser(User user ) async {
    user.password = BCrypt.hashpw(user.password, BCrypt.gensalt());
    String token = generateToken(); 
    if (!await isEmailUnique(user.email)){
      throw Exception("Email already exists");
    }
    final query = Query(
      'CREATE (u:User {username: \$username, password: \$password, email: \$email, token: \$token}) RETURN u',
      parameters: {
        'username': user.username,
        'password': user.password,
        'email': user.email,
        'token': BCrypt.hashpw(token, BCrypt.gensalt()), // Assuming you have a function to generate tokens
      },
    );
    try {
      // Execute the query
      final response = await client.execute([query]);

    if (response.results != null && response.results!.isNotEmpty) {
      var resultData = response.results!.first.data?.first;
      if (resultData != null) {
        // Extract the row data
        var row = resultData.row?.first;
        var meta = resultData.meta?.first;

        if (row != null && meta != null) {
          // Parse fields
          String password = row['password'];
          String email = row['email'];
          String username = row['username'];
          int id = meta['id'];

          // Create the User object
          User _user = User(
            id: id,
            password: password,
            username: username,
            email: email,
          );
      
          _currentUser = _user;
          tokenService.saveTokenToFile(token,_user.id);

          notifyListeners();

          print('User created: $currentUser');
          isLogin = true;
        }
      }
    }
 else {
        print('Failed to insert user');
      }
    } catch (e) {
      print('Error inserting user: $e');
    }
  }




  Future<void> loginUser(User user) async {
    final query = Query(
      'MATCH (u:User {username: \$username, email: \$email}) RETURN u',
      parameters: {'username': user.username,
                    'email': user.email},
    );

    try {
      // Execute the query to get the user by username
      final response = await client.execute([query]);
     

      if (response.results != null && response.results!.isNotEmpty) {
        var resultData = response.results!.first.data?.first;
        if (resultData != null) {
          // Extract the row data
          var row = resultData.row?.first;
           var meta = resultData.meta?.first;

          if (row != null) {
            String storedPassword = row['password'] ?? ''; // Stored password from the database
            String storedUsername = row['username'] ?? ''; // Stored username from the database
            String email = row['email'] ?? ''; // Email (if needed)
            
            // Verify if the provided password matches the stored password
            if (BCrypt.checkpw(user.password, storedPassword)) {
             
              User _user = User(
                id: meta['id'], // Assuming id is in row data
                username: user.email,
                password: storedPassword,
                email: user.email,
              );
              // _user.token = generateToken();
              // updateToken(user.email,user.email,BCrypt.hashpw(_user.token, BCrypt.gensalt()));

              _currentUser = _user;
              isLogin = true;
              await updateToken(_user.username, user.email,_user.id);
              notifyListeners();

              print('User logged in: $_currentUser');
            } else {
              throw Exception('Invalid password');
            }
          }
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('No user found with the username: ${user.username}');
      }
    } catch (e) {
      print('Error logging in: $e');
      throw Exception('Login failed: $e');
    }
  }


   Future<void> updateToken(String username,String email,int userId) async {
    String newToken =  generateToken();
    String bcryptToken =  BCrypt.hashpw(newToken,BCrypt.gensalt());
    final query = Query(
      'MATCH (u:User {username: \$username, email: \$email}) SET u.token = \$bcryptToken RETURN u',
      parameters: {
        'username': username,
        'email': email,
        'bcryptToken': bcryptToken
      },
    );

    try {
      final response = await client.execute([query]);
      print("========================================");
      print(response);
      if (response.results!.isNotEmpty) {
        print('Token updated successfully');
        tokenService.saveTokenToFile(newToken,userId);

      } else {
        print('Failed to update token');
      }
    } catch (e) {
      print('Error updating token: $e');
    }
  }

  Future<bool> isEmailUnique(String email) async {
    final query = Query(
      'MATCH (u:User {email: \$email}) RETURN u LIMIT 1',
      parameters: {'email': email},
    );
    final response = await client.execute([query]);
    return response.results!.first.data?.isEmpty ?? true;
  }


  bool verifyPassword(String plainPassword, String hashedPassword) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }
  String generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

}
