import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:health_management/Connection/Neo4jConnection.dart';
import 'package:health_management/Service/UserService.dart';
import 'package:health_management/di.dart';
import 'package:health_management/model/BMI.dart';
import 'package:neo4j_http_client/neo4j_http_client.dart';

class BMIService with ChangeNotifier{
  final client = Neo4jConnection.getClient();
  UserService get _UserService => sl<UserService>();
  List<BMI> _bmiHistory = [];
   
  List<BMI> get bmiHistory => _bmiHistory;

  Future<void> insertBMI(BMI BMI ) async {
    final query = Query(
      ''' MATCH (u:User)
          WHERE id(u) = \$id
          CREATE (b:BMI {
            dateTime: \$dateTime,
            age: \$age,
            weight: \$weight,
            height: \$height,
            bmiResult: \$bmiResult,
            bmiCategory: \$bmiCategory
          })
          CREATE (u)-[:HAS_BMI]->(b)
          RETURN b;
        ''',
      parameters: {
                   'id': _UserService.currentUser?.id,
                   'dateTime': BMI.dateTime.toIso8601String(),
                   'age': BMI.age,
                   'weight': BMI.weight,
                   'height': BMI.height, 
                   'bmiResult': BMI.bmiResult,
                   'bmiCategory': BMI.bmiCategory
                  },
    );
    try {
      final response = await client.execute([query]);
      if (response.results != null && response.results!.isNotEmpty) {
        var resultData = response.results!.first.data?.first;
      
        if (resultData != null) {
          var meta = resultData.meta?.first;
          BMI.id = meta['id'];
          _bmiHistory.add(BMI);
          await getBMIsForUser(_UserService.currentUser!.id);
          notifyListeners();
         }
      }else{
         throw Exception('No response ${response.results}');
      }

    }catch(e){
   
      throw Exception('Login failed: $e');
    }
    return null;
  }
  
  Future<void> getBMIsForUser(int userId) async {
    final query = Query(
      ''' MATCH (u:User)-[:HAS_BMI]->(b:BMI)
          WHERE id(u) = \$id
          RETURN b
      ''',
      parameters: {
        'id': userId,
      },
    );
    try {
      final response = await client.execute([query]);
      if (response.results != null && response.results!.isNotEmpty) {
        List<BMI> bmiList = [];
        int length =  response.results!.first.data!.length;

        for (int i = 0; i < length; i++) {
            var bmiNode = response.results!.first.data?[i];
            if (bmiNode != null) {
            BMI addBMI = BMI(
              dateTime: DateTime.parse(bmiNode.row?.first["dateTime"]),
              age: bmiNode.row?.first["age"],
              weight: bmiNode.row?.first["weight"],
              height: bmiNode.row?.first["height"],
              bmiResult: bmiNode.row?.first["bmiResult"],
              bmiCategory: bmiNode.row?.first["bmiCategory"],
            );
            addBMI.id = bmiNode.meta?.first["id"];

            bmiList.add(addBMI);
          }
        }
        _bmiHistory = bmiList;
        _bmiHistory.reversed;
        notifyListeners();
      } else {
        throw Exception('No BMI data found for user with ID: $userId');
      }
    } catch (e) {
      throw Exception('Failed to fetch BMI list: $e');
    }
  }
   Future<void> deleteBMI(int userId) async {
    final query = Query(
      ''' Match (b:BMI) <- [:HAS_BMI] -(u:User) 
          where id(b) = \$userId
          detach delete b 
          return u
      ''',
      parameters: {
        'userId': userId,
      },
    );
     try {
      final response = await client.execute([query]);
      await getBMIsForUser(_UserService.currentUser!.id);
      notifyListeners();
     }catch(e){
      print("error deleteing  $e");
     }

   }

  
}