// meal_home_screen.dart
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/calorie_tracker_home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/health_rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'meal.dart';

class MealHomeScreen extends StatelessWidget {
  final Meal meal;
  final String? imageUrl;

  MealHomeScreen({required this.meal, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Nutrition Detail'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl != "" ? Image.network(imageUrl!) : SizedBox(),
            Text(
              meal.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "CaloScanAI provides calorie and nutritional estimates intended to be helpful for reference purposes only. They should not be taken as completely precise figures and should not replace professional healthcare advice.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Learn More",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            // Nutrition Estimate Table
            Container(
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(132, 141, 185, 66),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nutrition Estimate",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.sp,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                              Text(
                                                "Edit",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Code for regenerate action
                                                },
                                                child: Text("Regenerate",
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "Updating the content will use 1 daily use",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: meal.nutrients
                                                    .where((nutrient) => ![
                                                          "Calories",
                                                          "Protein",
                                                          "Total Carbohydrate",
                                                          "Total Fat"
                                                        ].contains(
                                                            nutrient.name))
                                                    .map((nutrient) =>
                                                        _buildFoodItem(
                                                            nutrient))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: SizedBox(child: Icon(Icons.edit))),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Food item",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Weight/Volume",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Calories",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            meal.weight,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${meal.calories} Cal",
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey),
                  Container(
                    color: Colors.yellow[100],
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nutrient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        ...meal.nutrients.map(
                          (nutrient) =>
                              _buildNutrientRow(nutrient.name, nutrient.amount),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CalorieTrackerHome();
                }));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Refine Result"),
            ),
            SizedBox(height: 16),
            HealthRatingWidget(
              healthRating: // Example health rating (75%)
                  (0.3 +
                      (0.7 - 0.3) *
                          (new DateTime.now().millisecondsSinceEpoch % 1000) /
                          1000),
            ),
            SizedBox(height: 16),
            Text(
              "The Amount Eaten (Serving)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {},
                ),
                Text("1 Serving"),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  child: Text("Try another"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: Text("Log This Meal"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((nutrient)),
          Text(amount),
        ],
      ),
    );
  }
}

// Widget _buildFoodItem(String amount, String unit, String name,
//     {bool isAddMore = false}) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: TextField(
//             controller: TextEditingController(text: amount),
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               isDense: true,
//               suffixText: unit,
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//         Expanded(
//           flex: 5,
//           child: TextField(
//             controller: TextEditingController(text: name),
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               isDense: true,
//               hintText: isAddMore ? "Add more food" : null,
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//         IconButton(
//           icon: Icon(isAddMore ? Icons.add : Icons.close),
//           onPressed: () {
//             // Handle add or remove action
//           },
//         ),
//       ],
//     ),
//   );
// }
Widget _buildFoodItem(Nutrient nutrient, {bool isAddMore = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: TextEditingController(text: nutrient.amount),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              // suffixText: nutrient.unit, // Sử dụng đơn vị của nutrient
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: TextField(
            controller: TextEditingController(text: nutrient.name),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: isAddMore ? "Add more food" : null,
            ),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(isAddMore ? Icons.add : Icons.close),
          onPressed: () {
            // Handle add or remove action
          },
        ),
      ],
    ),
  );
}
