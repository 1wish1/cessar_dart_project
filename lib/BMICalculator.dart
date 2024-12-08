import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'LoginPage.dart' as Login;
import 'SignupPage.dart' as Signup;

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}



class _BMICalculatorState extends State<BMICalculator> {
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  List<String> _bmiHistory = [];

  double? _bmiResult;
  String _bmiCategory = '';
  String? _age;

  // Method to determine BMI category
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

  void _calculateBMI() {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    final int? _age = int.tryParse(_ageController.text);

    if (weight != null && height != null && height > 0) {
      setState(() {
        _bmiResult = weight / (height * height);
        _bmiCategory = _getBMICategory(_bmiResult!);
        
        // Get the current date and time
        String currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Add BMI details with date and time to the history
        _bmiHistory.add(
          "Date: $currentDateTime, Age: $_age, Weight: ${weight}, Height: ${height}, BMI: ${_bmiResult!} ($_bmiCategory)",
        );
      });
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
        return Colors.grey; // Default color for undefined categories
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
      return Colors.grey; // Default color for undefined categories
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Health Management'),
      actions: [
        Padding(
            padding: EdgeInsets.only(left: 5.0), // Add left margin to the first button
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login.LoginPage()),
                );
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
            padding: const EdgeInsets.only(right: 25.0), // Add left margin to the second button
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup.SignupPage()),
                );
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
      ],
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                          margin: const EdgeInsets.symmetric(vertical: 8.0), // Adds top and bottom spacing
                          decoration: BoxDecoration(
                            color: _getBackgroundColor(_bmiHistory[index]), // Background color
                            borderRadius: BorderRadius.circular(12.0), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Adds padding inside the container
                            child: ListTile(
                              leading: const Icon(Icons.history, color: Colors.teal),
                              title: Text(_bmiHistory[index]),
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
