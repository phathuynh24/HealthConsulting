import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/info/gender_selection_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/recipe_recommendation_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/water_tracker_widget.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/product_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieTrackerHome extends StatefulWidget {
  const CalorieTrackerHome({super.key});

  @override
  _CalorieTrackerHomeState createState() => _CalorieTrackerHomeState();
}

class _CalorieTrackerHomeState extends State<CalorieTrackerHome> {
  DateTime selectedDate = DateTime.now();
  final remainingCalories = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            (selectedDate.year == DateTime.now().year &&
                    selectedDate.month == DateTime.now().month &&
                    selectedDate.day == DateTime.now().day)
                ? "Hôm nay"
                : DateFormat('dd-MM-yyyy').format(selectedDate),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProductScanScreen(),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logged_meals')
            .where('loggedAt',
                isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final totalCalories = docs.fold<int>(
            0,
            (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              final calories = (data['calories'] ?? 0) as num;
              return sum + calories.toInt();
            },
          );

          return Column(
            children: [
              _buildCalorieSummary(totalCalories),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('user_goal_plans')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        // Check if the snapshot has data and is not loading
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // Show a loading indicator while waiting
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error: ${snapshot.error}')); // Show error if any
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GenderSelectionScreen()),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Mềm mại các góc
                              ),
                              elevation: 5, // Độ bóng nhẹ
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.greenAccent
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vui lòng nhấn vào để nhập thông tin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Màu chữ sáng trên nền gradient
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Chưa có thông tin về chiều cao, cân nặng và giới tính.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors
                                            .white70, // Màu chữ nhẹ nhàng, dễ nhìn
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // When data is available, parse the snapshot
                        final userDoc =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final height = userDoc['height'] ?? '0';
                        final weight = userDoc['weight'] ?? '0';
                        final gender = userDoc['gender'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GenderSelectionScreen()),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // Mềm mại các góc
                            ),
                            elevation:
                                8, // Độ bóng đổ mạnh hơn để tạo sự nổi bật
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin cơ thể:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // Màu chữ sáng trên nền cam
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoText('Chiều cao: ', '$height'),
                                  _buildInfoText('Cân nặng: ', '$weight'),
                                  _buildInfoText('Giới tính: ', gender),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMealEntry(
                        "Đề xuất món ăn", Icons.fastfood),
                    _buildMealTypeSection('Buổi sáng', Icons.breakfast_dining),
                    _buildMealTypeSection('Buổi trưa', Icons.lunch_dining),
                    _buildMealTypeSection('Buổi tối', Icons.dinner_dining),
                    _buildMealTypeSection('Ăn vặt', Icons.fastfood),
                    const Divider(),
                    _buildExerciseEntry(
                        "Exercise", Icons.directions_run, "0 Cal"),
                    _buildExerciseEntry(
                        "Daily steps", Icons.directions_walk, "5000 steps"),
                    WaterTrackerWidget()
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70, // Màu sắc nhẹ nhàng, dễ nhìn
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.isEmpty ? 'Chưa có' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Màu sắc nổi bật cho giá trị
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieSummary(int totalCalories) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logged_meals')
            .where('loggedAt',
                isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          // double totalCalories = 0;
          double totalCarbs = 0;
          double totalProtein = 0;
          double totalFat = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final nutrients = data['nutrients'] as List<dynamic>? ?? [];

            for (var nutrient in nutrients) {
              final nutrientData = nutrient as Map<String, dynamic>;
              final name = nutrientData['name'];
              final amount = nutrientData['amount'] ?? 0;

              if (name == "Total Carbohydrate") {
                totalCarbs += amount;
              } else if (name == "Protein") {
                totalProtein += amount;
              } else if (name == "Total Fat") {
                totalFat += amount;
              }
            }
          }
          totalCarbs = double.parse(totalCarbs.toStringAsFixed(1));
          totalProtein = double.parse(totalProtein.toStringAsFixed(1));
          totalFat = double.parse(totalFat.toStringAsFixed(1));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Calories",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text("Remaining = Goal - Food + Exercise"),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hiển thị hình tròn Calorie
                        _buildCircularCalorieDisplay(totalCalories),
                        // Thông tin chi tiết Calorie
                        _buildCalorieDetails(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutrientInfo("Carbs", "$totalCarbs"),
                        _buildNutrientInfo("Protein", "$totalProtein"),
                        _buildNutrientInfo("Fat", "$totalFat"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCircularCalorieDisplay(int totalCalories) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: totalCalories / 2502,
                strokeWidth: 8,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
              Center(
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('user_goal_plans')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, goalSnapshot) {
                    if (goalSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!goalSnapshot.hasData || goalSnapshot.data == null) {
                      return const Text("No goal data available");
                    }
                    final goalData =
                        goalSnapshot.data!.data() as Map<String, dynamic>;
                    final goal = (goalData['adjustedCalories'] ?? 0) as num;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('logged_meals')
                          .where('loggedAt',
                              isEqualTo:
                                  DateFormat('yyyy-MM-dd').format(selectedDate))
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, mealsSnapshot) {
                        if (mealsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final mealDocs = mealsSnapshot.data?.docs ?? [];
                        final totalCalories = mealDocs.fold<int>(
                          0,
                          (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final calories = (data['calories'] ?? 0) as num;
                            return sum + calories.toInt();
                          },
                        );

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('completed_exercises')
                              .where(
                                'completed_at',
                                isEqualTo: DateFormat('dd/MM/yyyy')
                                    .format(selectedDate),
                              )
                              .where('user_uid',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, exerciseSnapshot) {
                            if (exerciseSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final exerciseDocs =
                                exerciseSnapshot.data?.docs ?? [];
                            final totalCaloriesExercise =
                                exerciseDocs.fold<int>(
                              0,
                              (sum, doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final calories = (data['calo'] ?? 0) as num;
                                return sum + calories.toInt();
                              },
                            );

                            final remainingCalories =
                                goal - totalCalories + totalCaloriesExercise;

                            return Text(
                              '${remainingCalories.toInt()}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text("Remaining"),
      ],
    );
  }

  Widget _buildCalorieDetails() {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user_goal_plans')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("No data available");
          }
          final userDoc = snapshot.data!.data() as Map<String, dynamic>;
          final baseGoal = userDoc['adjustedCalories'] ?? '0';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text("Mục tiêu: ${baseGoal.toInt()}"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.blue),
                  const SizedBox(width: 4),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('logged_meals')
                          .where('loggedAt',
                              isEqualTo:
                                  DateFormat('yyyy-MM-dd').format(selectedDate))
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];
                        final totalCalories = docs.fold<int>(
                          0,
                          (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final calories = (data['calories'] ?? 0) as num;
                            return sum + calories.toInt();
                          },
                        );
                        return Text("Ăn uống: $totalCalories");
                      }),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.red),
                  const SizedBox(width: 4),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('completed_exercises')
                          .where(
                            'completed_at',
                            isEqualTo:
                                DateFormat('dd/MM/yyyy').format(selectedDate),
                          )
                          .where('user_uid',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];
                        final totalCaloriesExcercise = docs.fold<int>(
                          0,
                          (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final calories = (data['calo'] ?? 0) as num;
                            return sum + calories.toInt();
                          },
                        );
                        return Text("Tập luyện: $totalCaloriesExcercise");
                      }),
                ],
              ),
            ],
          );
        });
  }

  Widget _buildNutrientInfo(String nutrient, String value) {
    return Column(
      children: [
        Text(nutrient, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _buildExerciseEntry(String title, IconData icon, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: Text(value,
          style: const TextStyle(fontSize: 16, color: Colors.green)),
    );
  }

  Widget _buildMealEntry(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RecipeRecommendationScreen(
              defaultCalories: 2502,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealTypeSection(String mealType, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(mealType, style: const TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.add, color: Colors.green),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('logged_meals')
              .where('type', isEqualTo: mealType)
              .where('loggedAt',
                  isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final meals = snapshot.data?.docs ?? [];

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index].data() as Map<String, dynamic>;
                return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: meal['imageUrl'] != null &&
                              meal['imageUrl'].toString().startsWith('http')
                          ? Image.network(
                              meal['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fastfood),
                      title: Text(meal['customName'] ?? meal['originalName']),
                      subtitle: Text(
                        meal['loggedAt'] ?? '',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MealHomeScreen(
                              meal: Meal.fromMap(meal),
                              imageUrl: meal['imageUrl'] ?? '',
                            ),
                          ),
                        );
                      },
                    ));
              },
            );
          },
        )
      ],
    );
  }
}

Future<String> getGoalFromFirestore(String userId) async {
  try {
    final userDoc =
        FirebaseFirestore.instance.collection('user_goal_plans').doc(userId);

    // Lấy dữ liệu từ tài liệu
    final docSnapshot = await userDoc.get();

    // Kiểm tra xem tài liệu có tồn tại không
    if (docSnapshot.exists) {
      // Lấy giá trị của trường 'goal'
      String goal = docSnapshot.get('goal');
      return goal;
    } else {
      // Tài liệu không tồn tại
      return 'Không tìm thấy dữ liệu';
    }
  } catch (e) {
    // Xử lý lỗi nếu có
    return 'Lỗi: $e';
  }
}
