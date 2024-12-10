import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:health_management/Service/BMIService.dart';
import 'package:health_management/Service/UserService.dart';
import 'package:health_management/di.dart';
import 'package:health_management/model/BMI.dart';
import 'package:health_management/model/User.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart' as Login;
import 'SignupPage.dart' as Signup;
import 'package:get_it/get_it.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}



class _BMICalculatorState extends State<BMICalculator> {
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
   UserService get userService => sl<UserService>();
    BMIService get _BMIService => sl<BMIService>();
   
  List<BMI> _bmiHistory = [];

  double? _bmiResult;
  String _bmiCategory = '';
  User? user;


  void initState() {
    super.initState();
    user = userService.currentUser;  
    if(user != null){
      setState(() {
        _bmiHistory = _BMIService.bmiHistory;
      });
    }
  }

  
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  Future<void> _calculateBMI() async {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    final int? _age = int.tryParse(_ageController.text);

    if (weight != null && height != null && height > 0) {
      
      final double bmiResult = weight / (height * height);
      final String bmiCategory = _getBMICategory(bmiResult);

     
      final DateTime currentDateTime = DateTime.now();

      BMI? bmi = BMI(
            age: _age,
            dateTime: currentDateTime,
            height: height,
            weight: weight,
            bmiCategory: bmiCategory,
            bmiResult: bmiResult,
          );

      if (userService.isLogin) {

       await _BMIService.insertBMI(bmi);
       setState(() {
        _bmiHistory = _BMIService.bmiHistory;
        });

      }else{
        setState(() {
        _bmiHistory.insert(0,bmi);
        });
      }

      
    }
  }
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal weight':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey; 
    }
  }
  Color _getBackgroundColor(String bmiCategory) {
    if (bmiCategory.contains('Underweight')) {
      return Colors.blue;
    } else if (bmiCategory.contains('Normal')) {
      return Colors.green;
    } else if (bmiCategory.contains('Overweight')) {
      return Colors.orange;
    } else if (bmiCategory.contains('Obese')) {
      return Colors.red;
    } else {
      return Colors.grey; 
    }
  }
  void _deleteHistorySign(int id,int index) {
    
    _BMIService.deleteBMI(id);
    setState(() {
      _bmiHistory.removeAt(index);
    });
  }
  void _deleteHistoryGuest(int index) {
    setState(() {
      _bmiHistory.removeAt(index);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
      title: const Text('Health Management'),
      actions: [
       
      if (!userService.isLogin) ...[
        Padding(
          padding: EdgeInsets.only(left: 5.0), 
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 25.0), 
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/signup");
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Signup',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ),
      ] else ...[
        Padding(
          padding: const EdgeInsets.only(right: 25.0), 
          child: TextButton(
            onPressed: () {
              userService.logout(); 
               setState(() {
                user = null;
                _bmiHistory.clear();

              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => BMICalculator()),
              );
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ),
      ],
    ],
    ),
      body: 
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: 
        Column(
          children: [
              Text(
              userService.isLogin 
              ? 'Hi, ${userService.currentUser?.username}!' 
              : 'Hi, Guest!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Enter Your Details',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height (m)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateBMI,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Calculate BMI', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_bmiResult != null)
              Card(
                color: _getCategoryColor(_bmiCategory),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI: ${_bmiResult!}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Category: $_bmiCategory',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI History:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bmiHistory.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: _getBackgroundColor(_bmiHistory[index].toString()), 
                            borderRadius: BorderRadius.circular(12.0), 
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), 
                            child: ListTile(
                              leading: const Icon(Icons.history, color: Color.fromARGB(255, 84, 97, 96)),
                              title: Text(_bmiHistory[index].toString()),
                              trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 202, 214, 208)),
                                onPressed: () {
                                  if(userService.isLogin){  
                                    _deleteHistorySign(_bmiHistory[index].id,index);
                                  }else{
                                    _deleteHistoryGuest(index);
                                  }
                                } 
                              ),
                            ),
                            
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
