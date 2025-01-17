import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/utils/base_url.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  final File image;

  const ProductScreen({super.key, required this.image});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  bool isLoading = false;

  // Trạng thái dữ liệu đã nhập
  bool isHealthInfoEntered = false;

  Future<void> uploadImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(ApiConstants.getPredictNutritionUrl());

    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', widget.image.path))
      ..fields['description'] = _descriptionController.text;

    // Thêm đường huyết vào yêu cầu nếu có
    if (_bloodSugarController.text.isNotEmpty) {
      request.fields['blood_sugar'] = _bloodSugarController.text;
    }

    // Thêm huyết áp vào yêu cầu nếu có
    if (_systolicController.text.isNotEmpty &&
        _diastolicController.text.isNotEmpty) {
      request.fields['blood_pressure'] = jsonEncode({
        "systolic": int.tryParse(_systolicController.text) ?? 0,
        "diastolic": int.tryParse(_diastolicController.text) ?? 0,
      });
    }

    var response = await request.send();
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      print('Response: $data');

      if (data.containsKey("predictions_model")) {
        var foodName = data["name"];
        double calories =
            (data["nutrition_info"]["calories"] as num?)?.toDouble() ?? 0.0;
        double protein =
            (data["nutrition_info"]["protein"] as num?)?.toDouble() ?? 0.0;
        double totalCarbs =
            (data["nutrition_info"]["total_carbohydrate"] as num?)
                    ?.toDouble() ??
                0.0;
        double totalFat =
            (data["nutrition_info"]["total_fat"] as num?)?.toDouble() ?? 0.0;
        double servingWeight =
            (data["nutrition_info"]["serving_weight_grams"] as num?)
                    ?.toDouble() ??
                0.0;

        List<Nutrition> nutrients = [
          Nutrition(name: "Protein", amount: protein),
          Nutrition(name: "Total Carbohydrate", amount: totalCarbs),
          Nutrition(name: "Total Fat", amount: totalFat),
        ];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealHomeScreen(
              meal: Meal(
                name: foodName,
                weight: servingWeight,
                calories: calories,
                nutrients: nutrients,
                ingredients: [],
                warnings: data['warnings'] ?? [],
              ),
              imageUrl: widget.image.path,
            ),
          ),
        );
      } else if (data.containsKey("gemini_result")) {
        var totalNutrition = data["total_nutrition"]["total_nutrition"];
        double calories =
            (totalNutrition["calories"] as num?)?.toDouble() ?? 0.0;
        double protein = (totalNutrition["protein"] as num?)?.toDouble() ?? 0.0;
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

        List<Nutrition> nutrients = [
          Nutrition(name: "Protein", amount: protein),
          Nutrition(name: "Total Carbohydrate", amount: totalCarbs),
          Nutrition(name: "Total Fat", amount: totalFat),
        ];

        var ingredients = data["ingredients"];
        var nameEnglish = ingredients
            .map((ingredient) => ingredient["name_english"])
            .toList();
        var nameVietnamese = ingredients
            .map((ingredient) => ingredient["name_vietnamese"])
            .toList();

        var detailIngredients = data["total_nutrition"]["detailed_nutrition"];
        double totalWeight = detailIngredients.fold(0.0, (sum, ingredient) {
          String quantity = ingredient["quantity"];
          double weight = double.tryParse(quantity.split(" ")[0]) ?? 0.0;
          return sum + weight;
        });

        List<Ingredient> ingredientsList = [];

        ingredientsList.addAll(detailIngredients.map<Ingredient>((ingredient) {
          String name = ingredient["name"];
          String quantity = ingredient["quantity"];
          double ingredientCalories =
              (ingredient["calories"] as num?)?.toDouble() ?? 0.0;

          return Ingredient(
            name_en: nameEnglish[nameEnglish.indexOf(name)],
            name_vi: nameVietnamese[nameEnglish.indexOf(name)],
            quantity: double.tryParse(quantity.split(" ")[0]) ?? 0.0,
            calories: ingredientCalories,
          );
        }).toList());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealHomeScreen(
              meal: Meal(
                name: dishName,
                weight: totalWeight,
                calories: calories,
                nutrients: nutrients,
                ingredients: ingredientsList,
                warnings: data['warnings'] ?? [],
              ),
              imageUrl: widget.image.path,
            ),
          ),
        );
      } else {
        print("Unknown response format.");
        showErrorDialog(context, "Phản hồi không xác định.");
      }
    } else {
      print("Failed to upload image: ${response.statusCode}");
      showErrorDialog(
          context, "Không thể tải lên ảnh. Mã lỗi: ${response.statusCode}");
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lỗi"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Hàm mở BottomSheet để nhập thông tin sức khỏe
  void _showHealthInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nhập thông tin sức khỏe",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: "Đường huyết (mg/dL)",
                controller: _bloodSugarController,
                hint: "Ví dụ: 110",
                icon: Icons.water_drop,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: "Huyết áp tâm thu (mmHg)",
                      controller: _systolicController,
                      hint: "Ví dụ: 120",
                      icon: Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInputField(
                      label: "Huyết áp tâm trương (mmHg)",
                      controller: _diastolicController,
                      hint: "Ví dụ: 80",
                      icon: Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHealthInfoEntered = true;
                      });
                      Navigator.pop(context); // Đóng BottomSheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Lưu thông tin",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Xóa dữ liệu và cập nhật trạng thái
                        _bloodSugarController.clear();
                        _systolicController.clear();
                        _diastolicController.clear();
                        isHealthInfoEntered = false;
                      });
                      Navigator.pop(context); // Đóng BottomSheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Xoá dữ liệu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận thông tin món ăn'),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Xác nhận và chỉnh sửa thông tin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.image,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isLoading)
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showHealthInfoSheet(context),
                  icon: Icon(
                    isHealthInfoEntered
                        ? Icons.check_circle
                        : Icons.health_and_safety,
                    color: isHealthInfoEntered ? Colors.green : Colors.blue,
                  ),
                  label: Text(
                    isHealthInfoEntered
                        ? "Đã nhập: ${_bloodSugarController.text} mg/dL, ${_systolicController.text}/${_diastolicController.text} mmHg"
                        : "Nhấn để nhập thông tin sức khỏe",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: "Mô tả món ăn",
                  controller: _descriptionController,
                  hint: "Ví dụ: Hamburger phô mai với thịt bò và rau",
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    uploadImage(context);
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Tải lên thông tin'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: const Color(0xFF1565C0)) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF64B5F6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
      ),
    );
  }
}
