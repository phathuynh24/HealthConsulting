import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'meal.dart';

class FavoriteMealsScreen extends StatefulWidget {
  @override
  _FavoriteMealsScreenState createState() => _FavoriteMealsScreenState();
}

class _FavoriteMealsScreenState extends State<FavoriteMealsScreen> {
  // Remove a meal from favorite list
  Future<void> _deleteFavoriteMeal(String docId) async {
    await FirebaseFirestore.instance
        .collection('favorite_meals')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Đã xoá món ăn khỏi danh sách yêu thích!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent),
    );
  }

  // Edit meal name
  Future<void> _editMealName(String docId, String currentName) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);

    // Show dialog to edit meal name
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chỉnh sửa tên món ăn"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Tên mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('favorite_meals')
                      .doc(docId)
                      .update({'customName': _nameController.text});
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tên món ăn đã được cập nhật!",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.greenAccent,
                    ),
                  );
                }
              },
              child: Text("Lưu"),
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
        toolbarHeight: 80,
        title: Column(
          children: [
            const Text(
              'Danh sách món ăn yêu thích',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.9),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextFormField(
                // controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Tên món ăn',
                  hintStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                    size: 23,
                  ),
                  border: InputBorder.none,
                  suffixIconConstraints:
                      const BoxConstraints(maxHeight: 30, maxWidth: 30),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        // _searchText = '';
                        // _searchController.text = _searchText;
                      });
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(
                        right: 10,
                      ),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.clear,
                          size: 15,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // _searchText = value;
                    // _searchController.text = _searchText;
                  });
                },
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Get favorite meals from Firestore
        stream: FirebaseFirestore.instance
            .collection('favorite_meals')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return const Center(
                child:
                    Text("Đã xảy ra lỗi khi tải dữ liệu! Vui lòng thử lại."));
          }
          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có món ăn yêu thích nào!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Data loaded
          final meals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final docId = meal.id;
              final name = meal['customName'] ?? meal['originalName'];
              final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
              final weight = (meal['weight'] as num?)?.toDouble() ?? 0.0;
              final imageUrl = meal['imageUrl'] ?? "";

              // Convert nutrients and ingredients to list of objects
              List<Nutrition> nutrients = (meal['nutrients'] as List<dynamic>?)
                      ?.map((n) => Nutrition(
                            name: n['name'] ?? "",
                            amount: (n['amount'] as num?)?.toDouble() ?? 0.0,
                          ))
                      .toList() ??
                  [];

              List<Ingredient> ingredients =
                  (meal['ingredients'] as List<dynamic>?)
                          ?.map((i) => Ingredient(
                                name_en: i['name_en'] ?? "",
                                name_vi: i['name_vi'] ?? "",
                                quantity:
                                    (i['quantity'] as num?)?.toDouble() ?? 0.0,
                                calories:
                                    (i['calories'] as num?)?.toDouble() ?? 0.0,
                              ))
                          .toList() ??
                      [];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 4,
                child: InkWell(
                  // Navigate to meal details screen
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealHomeScreen(
                          meal: Meal(
                            name: name,
                            calories: calories,
                            weight: weight,
                            nutrients: nutrients,
                            ingredients: ingredients,
                            warnings: meal['warnings'] ?? [],
                          ),
                          imageUrl: imageUrl,
                          isFavorite: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.fastfood,
                                size: 60, color: Colors.grey),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Calories: $calories kcal",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            "Khối lượng: $weight g",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editMealName(docId, name);
                          } else if (value == 'delete') {
                            _deleteFavoriteMeal(docId);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text("Chỉnh sửa"),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Xóa"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
