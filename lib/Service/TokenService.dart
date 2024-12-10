import 'dart:convert';
import 'dart:io';

import 'package:health_management/model/Authentication.dart';

class TokenService{
  
  Future<Authentication?> getAuthenticationFromFile() async {
    final file = File('lib/log/token.json');

  
    if (await file.exists()) {
      try {
       
        final jsonString = await file.readAsString();

     
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

       
        return Authentication.fromJson(jsonMap);
      } catch (e) {
        print('Error reading or parsing token file: $e');
        return null;
      }
    } else {
      print('Token file does not exist');
      return null;
    }
  }
  Future<void> saveTokenToFile(String token,int userId) async {
    final file = File('lib/log/token.json');

   
    final tokenData = {
      'token': token,
      'userId':userId,
      'createdAt': DateTime.now().toIso8601String(),
      'ExpiresIn': 3600 
    };

    final jsonString = jsonEncode(tokenData);

   
    final directory = Directory('lib/log');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

   
    try {
      await file.writeAsString(jsonString, mode: FileMode.writeOnly);
      print('Token saved to log/token.json');
    } catch (e) {
      print('Error saving token to file: $e');
    }
  }
  Future<void> deleteTokenFile() async {
    final file = File('lib/log/token.json');

    try {
      if (await file.exists()) {
        await file.delete();
        print('Token file deleted successfully.');
      } else {
        print('Token file does not exist.');
      }
    } catch (e) {
      print('Error deleting token file: $e');
    }
  }

}