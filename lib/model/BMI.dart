import 'dart:ffi';

class BMI {
  final DateTime dateTime;
  final int age;
  final Float weight;
  final Float height;
  final Float bmiResult;
  final String bmiCategory;

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
      weight: map['weight'] as Float,
      height: map['height'] as Float,
      bmiResult: map["bmiResult"] as Float,
      bmiCategory: map["bmiCategory"] as String
    );
  }

  @override
  String toString() {
    return 'User(dateTime: $dateTime, age: $age, weight: $weight, height: $height, bmiResult: $bmiResult,bmiCategory: $bmiCategory,)';
  }
}
