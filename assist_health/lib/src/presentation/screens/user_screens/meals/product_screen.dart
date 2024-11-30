import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Screen2 extends StatefulWidget {
  final File image;

  Screen2({required this.image});

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;
  // Function to upload the image and description to the server
  Future<void> uploadImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse("http://10.0.2.2:5000/predict");

    // Create a multipart request with the image and description
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', widget.image.path))
      ..fields['description'] =
          _descriptionController.text; // Add description as form field

    try {
      var response = await request.send();
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);

        if (data.containsKey("predictions_model")) {
          // Handle response from the AI model
          var predictions = data["predictions_model"];
          String foodName = predictions["name"];
          double calories =
              (predictions["nutrition_info"]["calories"] as num?)?.toDouble() ??
                  0.0;
          double protein =
              (predictions["nutrition_info"]["protein"] as num?)?.toDouble() ??
                  0.0;
          double totalCarbs =
              (predictions["nutrition_info"]["total_carbohydrate"] as num?)
                      ?.toDouble() ??
                  0.0;
          double totalFat = (predictions["nutrition_info"]["total_fat"] as num?)
                  ?.toDouble() ??
              0.0;
          double servingWeight =
              (predictions["nutrition_info"]["serving_weight_grams"] as num?)
                      ?.toDouble() ??
                  0.0;
          String highresImageUrl =
              predictions["nutrition_info"]["highres_image_url"];

          List<Nutrient> nutrients = [
            Nutrient(name: "Calories", amount: "${calories} kcal"),
            Nutrient(name: "Protein", amount: "${protein} g"),
            Nutrient(name: "Total Carbohydrate", amount: "${totalCarbs} g"),
            Nutrient(name: "Total Fat", amount: "${totalFat} g"),
          ];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealHomeScreen(
                meal: Meal(
                  name: foodName,
                  weight: "${servingWeight}g",
                  calories: calories.toInt(),
                  nutrients: nutrients,
                ),
                imageUrl: widget.image.path,
              ),
            ),
          );
        } else if (data.containsKey("gemini_result")) {
          // Handle response from the Gemini model
          var totalNutrition = data["total_nutrition"]["total_nutrition"];
          double calories =
              (totalNutrition["calories"] as num?)?.toDouble() ?? 0.0;
          double protein =
              (totalNutrition["protein"] as num?)?.toDouble() ?? 0.0;
          double totalCarbs =
              (totalNutrition["total_carbohydrate"] as num?)?.toDouble() ?? 0.0;
          double totalFat =
              (totalNutrition["total_fat"] as num?)?.toDouble() ?? 0.0;

          var geminiResult = data["gemini_result"];
          var englishNameMatch =
              RegExp(r'English:\s*([^,]+)').firstMatch(geminiResult);
          String dishName = englishNameMatch != null
              ? englishNameMatch.group(1) ?? "Dish"
              : "Dish";

          var ingredients = data["total_nutrition"]["detailed_nutrition"];
          double totalWeight = ingredients.fold(0.0, (sum, ingredient) {
            String quantity = ingredient["quantity"];
            double weight = double.tryParse(quantity.split(" ")[0]) ?? 0.0;
            return sum + weight;
          });

          List<Nutrient> nutrients = [
            Nutrient(name: "Calories", amount: "${calories} kcal"),
            Nutrient(name: "Protein", amount: "${protein} g"),
            Nutrient(name: "Total Carbohydrate", amount: "${totalCarbs} g"),
            Nutrient(name: "Total Fat", amount: "${totalFat} g"),
          ];

          nutrients.addAll(ingredients.map<Nutrient>((ingredient) {
            String name = ingredient["name"];
            String quantity = ingredient["quantity"];
            double ingredientCalories =
                (ingredient["calories"] as num?)?.toDouble() ?? 0.0;

            return Nutrient(
              name: name,
              amount: "${quantity}, ${ingredientCalories} kcal",
            );
          }).toList());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealHomeScreen(
                meal: Meal(
                  name: dishName,
                  weight: "${totalWeight} g",
                  calories: calories.toInt(),
                  nutrients: nutrients,
                ),
                imageUrl: "", // Add image URL here if available
              ),
            ),
          );
        } else {
          print("Unknown response format.");
        }
      } else {
        print("Failed to upload image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context);
    }
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to upload image. Please try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Image and description'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confirm your photo?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      widget.image,
                      width: 600,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                    if (isLoading) CircularProgressIndicator(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.grey[600]),
                  decoration: InputDecoration(
                    labelText: "Enter a description of the food",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send,
                          color: Colors.grey[600]), // Màu của icon nhạt hơn
                      onPressed: () => uploadImage(context),
                      tooltip: "Send",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
