import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Screen2 extends StatelessWidget {
  final File image;

  Screen2({required this.image});

  // Hàm gửi ảnh qua POST và nhận lại thông tin từ API
  Future<void> uploadImage(BuildContext context) async {
    final url = Uri.parse("http://10.0.2.2:5000/predict");
    print("121");
    // Tạo yêu cầu multipart với ảnh
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print(response);
        // Giải mã response body để lấy dữ liệu dinh dưỡng
        var responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);

        // Truy xuất dữ liệu từ JSON response theo cấu trúc mới
        var predictions = data["predictions_model"];
        String foodName = predictions["name"];

        // Ensure that numeric fields are converted to double, using `toDouble()` if necessary.
        double calories = (predictions["nutrition_info"]["calories"] is int
            ? (predictions["nutrition_info"]["calories"] as int).toDouble()
            : predictions["nutrition_info"]["calories"]).toDouble();

        double protein = (predictions["nutrition_info"]["protein"] is int
            ? (predictions["nutrition_info"]["protein"] as int).toDouble()
            : predictions["nutrition_info"]["protein"]).toDouble();

        double totalCarbs = (predictions["nutrition_info"]["total_carbohydrate"] is int
            ? (predictions["nutrition_info"]["total_carbohydrate"] as int).toDouble()
            : predictions["nutrition_info"]["total_carbohydrate"]).toDouble();

        double totalFat = (predictions["nutrition_info"]["total_fat"] is int
            ? (predictions["nutrition_info"]["total_fat"] as int).toDouble()
            : predictions["nutrition_info"]["total_fat"]).toDouble();

        double servingWeight = (predictions["nutrition_info"]["serving_weight_grams"] is int
            ? (predictions["nutrition_info"]["serving_weight_grams"] as int).toDouble()
            : predictions["nutrition_info"]["serving_weight_grams"]).toDouble();

        String servingUnit = predictions["nutrition_info"]["serving_unit"];
        String highresImageUrl = predictions["nutrition_info"]["highres_image_url"];

        // Tạo danh sách các chất dinh dưỡng để hiển thị
        List<Nutrient> nutrients = [
          Nutrient(name: "Calories", amount: "${calories} kcal"),
          Nutrient(name: "Protein", amount: "${protein} g"),
          Nutrient(name: "Total Carbohydrate", amount: "${totalCarbs} g"),
          Nutrient(name: "Total Fat", amount: "${totalFat} g"),
        ];

        // Chuyển tới màn hình MealHomeScreen với thông tin dinh dưỡng nhận được
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealHomeScreen(
              meal: Meal(
                name: foodName,
                weight: "${servingWeight}g (${servingUnit})",
                calories: calories.toInt(),
                nutrients: nutrients,
              ),
              imageUrl: highresImageUrl, // Truyền link ảnh nếu cần dùng trong MealHomeScreen
            ),
          ),
        );
      } else {
        print("Failed to upload image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ảnh đã chụp")),
      body: Center(
        child: Image.file(image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => uploadImage(context), // Gọi hàm upload khi nhấn nút
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
