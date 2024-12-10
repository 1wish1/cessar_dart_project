import 'dart:ffi';

class BMI {
  final DateTime dateTime;
  final int? age;
  final double weight;
  final double height;
  final double? bmiResult;
  final String bmiCategory;
  late int id;

  BMI({
    required this.dateTime,
    required this.age,
    required this.weight, 
    required this.height,
    required this.bmiResult,
    required this.bmiCategory,
  });
  
  // Factory method to create a User from a map
  factory BMI.fromMap(Map<String, dynamic> map) {
    return BMI(
      dateTime: map['username'] as DateTime,
      age: map['age'] as int,
      weight: map['weight'] as double,
      height: map['height'] as double,
      bmiResult: map["bmiResult"] as double,
      bmiCategory: map["bmiCategory"] as String
    );
  }

  @override
  String toString() {
    return 'DateTime: $dateTime, Age: $age, Weight: $weight, Height: $height, BMIResult: $bmiResult, BMICategory: $bmiCategory,)';
  }
}
