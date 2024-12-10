
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_management/Service/BMIService.dart';
import 'package:health_management/Service/TokenService.dart';
import 'package:health_management/di.dart';
import 'package:health_management/model/BMI.dart';
import 'package:health_management/model/User.dart';
import 'package:neo4j_http_client/neo4j_http_client.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:health_management/model/User.dart';

import '../Connection/Neo4jConnection.dart';

class UserService with ChangeNotifier{
 
  final client = Neo4jConnection.getClient();

  TokenService get tokenService => sl<TokenService>();
  BMIService get _BMIService => sl<BMIService>();
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
        'token': BCrypt.hashpw(token, BCrypt.gensalt()), 
      },
    );


    try {
     
      final response = await client.execute([query]);

    if (response.results != null && response.results!.isNotEmpty) {
      var resultData = response.results!.first.data?.first;
      if (resultData != null) {
    
        var row = resultData.row?.first;
        var meta = resultData.meta?.first;

        if (row != null && meta != null) {
    
          String password = row['password'];
          String email = row['email'];
          String username = row['username'];
          int id = meta['id'];

      
          User _user = User(
            id: id,
            password: password,
            username: username,
            email: email,
          );
      
          _currentUser = _user;
          tokenService.saveTokenToFile(token,_user.id);
          isLogin = true;
          _BMIService.getBMIsForUser(_user.id);
          notifyListeners();

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
   
      final response = await client.execute([query]);
     

      if (response.results != null && response.results!.isNotEmpty) {
        var resultData = response.results!.first.data?.first;
        if (resultData != null) {
        
          var row = resultData.row?.first;
           var meta = resultData.meta?.first;

          if (row != null) {
            String storedPassword = row['password'] ?? ''; 
            String storedUsername = row['username'] ?? ''; 
            String email = row['email'] ?? ''; 
            
           
            if (BCrypt.checkpw(user.password, storedPassword)) {
             
              User _user = User(
                id: meta['id'], 
                username: user.email,
                password: storedPassword,
                email: user.email,
              );
             

              _currentUser = _user;
              _BMIService.getBMIsForUser(_user.id);
              isLogin = true;
              await updateToken(_user.username, user.email,_user.id);
              notifyListeners();

            } else {
              throw Exception('Invalid password');
            }
          }
        } 
      } else {
        throw Exception('No user found with the username: ${user.username}');
      }
    } catch (e) {
      throw Exception('Login failed no User found ');
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
  Future<void> logout() async {
    tokenService.deleteTokenFile();
    _currentUser == null;
    isLogin = false;
    notifyListeners();
  }

}
