import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(BMIApp());
}

class BMIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double height = 170;
  int weight = 60;
  int age = 20;
  String gender = "Male";

  void calculateBMI() {
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);

    String category;
    String advice;

    if (bmi < 18.5) {
      category = "Underweight";
      advice =
          "You should eat more nutritious food and maintain a healthy diet.";
    } else if (bmi < 25) {
      category = "Normal";
      advice = "Great! Maintain your current lifestyle and stay active.";
    } else if (bmi < 30) {
      category = "Overweight";
      advice = "Try regular exercise and control your diet.";
    } else {
      category = "Obese";
      advice = "Consult a doctor and follow a proper fitness plan.";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          bmi: bmi,
          category: category,
          age: age,
          advice: advice,
        ),
      ),
    );
  }

  Widget glassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget genderButton(String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            gender = value;
          });
        },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: gender == value ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: gender == value ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget weightControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (weight > 1) weight--;
            });
          },
          icon: Icon(Icons.remove, color: Colors.white),
        ),
        Text("$weight kg", style: TextStyle(fontSize: 24, color: Colors.white)),
        IconButton(
          onPressed: () {
            setState(() {
              weight++;
            });
          },
          icon: Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget ageControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (age > 1) age--;
            });
          },
          icon: Icon(Icons.remove, color: Colors.white),
        ),
        Text("$age yrs", style: TextStyle(fontSize: 24, color: Colors.white)),
        IconButton(
          onPressed: () {
            setState(() {
              age++;
            });
          },
          icon: Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // IMAGE / LOGO
                  Image.asset("assets/images/fitness.png", height: 140),

                  SizedBox(height: 15),

                  Text("BMI Calculator",
                      style: TextStyle(fontSize: 28, color: Colors.white)),

                  SizedBox(height: 20),

                  // GENDER
                  glassCard(Row(
                    children: [
                      genderButton("Male"),
                      SizedBox(width: 10),
                      genderButton("Female"),
                    ],
                  )),

                  SizedBox(height: 20),

                  // HEIGHT
                  glassCard(Column(
                    children: [
                      Text("Height", style: TextStyle(color: Colors.white)),
                      Text("${height.toInt()} cm",
                          style: TextStyle(fontSize: 26, color: Colors.white)),
                      Slider(
                        value: height,
                        min: 100,
                        max: 220,
                        onChanged: (value) {
                          setState(() {
                            height = value;
                          });
                        },
                      )
                    ],
                  )),

                  SizedBox(height: 20),

                  // WEIGHT
                  glassCard(Column(
                    children: [
                      Text("Weight", style: TextStyle(color: Colors.white)),
                      weightControl(),
                    ],
                  )),

                  SizedBox(height: 20),

                  // AGE
                  glassCard(Column(
                    children: [
                      Text("Age", style: TextStyle(color: Colors.white)),
                      ageControl(),
                    ],
                  )),

                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("CALCULATE", style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final double bmi;
  final String category;
  final int age;
  final String advice;

  ResultScreen({
    required this.bmi,
    required this.category,
    required this.age,
    required this.advice,
  });

  Color getColor() {
    if (category == "Normal") return Colors.green;
    if (category == "Underweight") return Colors.orange;
    if (category == "Overweight") return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, getColor()],
          ),
        ),
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 10,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Your BMI", style: TextStyle(fontSize: 22)),
                  SizedBox(height: 10),
                  Text(bmi.toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(category,
                      style: TextStyle(fontSize: 20, color: getColor())),
                  SizedBox(height: 10),
                  Text("Age: $age", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  Text(
                    advice,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Recalculate"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
