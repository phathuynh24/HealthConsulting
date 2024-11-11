import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Screen2 extends StatelessWidget {
  final File image;

  Screen2({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ảnh đã chụp")),
      body: Center(
        child: Image.file(image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealHomeScreen(
                meal: Meal(
                  name: "Chicken Noodle Soup",
                  weight: "300ml",
                  calories: 200,
                  nutrients: [
                    Nutrient(name: "Total Carbs", amount: "20g"),
                    Nutrient(name: "Total Protein", amount: "15g"),
                    Nutrient(name: "Total Fat", amount: "5g"),
                    Nutrient(name: "Total Dietary Fiber", amount: "2g"),
                  ],
                ),
              ),
            ),
          );
        },
        child: Icon(Icons.info),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết")),
      body: Center(
        child: Text("Chi tiết sản phẩm"),
      ),
    );
  }
}
