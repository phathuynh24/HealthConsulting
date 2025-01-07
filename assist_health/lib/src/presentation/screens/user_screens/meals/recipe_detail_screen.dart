// import 'package:flutter/material.dart';
// import 'package:assist_health/src/others/theme.dart';

// class RecipeDetails extends StatefulWidget {
//   final Map<String, dynamic> recipe;

//   const RecipeDetails({Key? key, required this.recipe}) : super(key: key);

//   @override
//   _RecipeDetailsState createState() => _RecipeDetailsState();
// }

// class _RecipeDetailsState extends State<RecipeDetails> {
//   bool isSave = false;

//   void saveRecipe(Map<String, dynamic> recipe) {
//     // print('Món ăn đã được lưu: ${recipe['title_translated']}');
//     // Thêm logic lưu món ăn vào cơ sở dữ liệu hoặc trạng thái
//   }

//   void unsaveRecipe(Map<String, dynamic> recipe) {
//     // print('Món ăn đã bị xóa khỏi danh sách lưu: ${recipe['title_translated']}');
//     // Thêm logic hủy lưu món ăn
//   }

//   @override
//   Widget build(BuildContext context) {
//     final recipe = widget.recipe;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(recipe['title_translated'] ?? 'Chi tiết món ăn'),
//         foregroundColor: Colors.white,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               isSave ? Icons.bookmark_added : Icons.bookmark_add_outlined,
//               color: isSave ? Colors.yellow : Colors.white,
//             ), // Biểu tượng thay đổi theo trạng thái
//             tooltip: isSave ? 'Đã lưu món ăn' : 'Lưu món ăn',
//             iconSize: 35,
//             onPressed: () {
//               setState(() {
//                 isSave = !isSave;
//                 if (isSave) {
//                   saveRecipe(recipe); // Lưu món ăn
//                 } else {
//                   unsaveRecipe(recipe); // Hủy lưu món ăn
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (recipe['image'] != null)
//               Center(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.network(
//                     recipe['image'],
//                     height: 250,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 16),
//             Text(
//               recipe['title_translated'] ?? 'Không có tiêu đề',
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//                 'Thời gian chuẩn bị: ${recipe['readyInMinutes'] ?? 'N/A'} phút',
//                 style: const TextStyle(fontSize: 16)),
//             Text('Khẩu phần: ${recipe['servings'] ?? 'N/A'} khẩu phần',
//                 style: const TextStyle(fontSize: 16)),
//             Text('Lượt thích: ${recipe['aggregateLikes'] ?? 'N/A'}',
//                 style: const TextStyle(fontSize: 16)),
//             Text('Điểm sức khỏe: ${recipe['healthScore'] ?? 'N/A'}',
//                 style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 16),
//             if (recipe['diets'] != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Chế độ ăn phù hợp:',
//                       style:
//                           TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(
//                       height: 8), // Khoảng cách nhỏ giữa tiêu đề và chip
//                   Wrap(
//                     spacing: 8.0, // Khoảng cách ngang giữa các chip
//                     runSpacing: 4.0, // Khoảng cách dọc giữa các dòng chip
//                     children: List.generate(recipe['diets'].length, (index) {
//                       return Chip(
//                         label: Text(
//                           recipe['diets'][index],
//                           style: const TextStyle(
//                               fontSize: 14, color: Colors.white),
//                         ),
//                         backgroundColor: Colors.teal, // Màu nền chip
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 4.0),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 16),
//             if (recipe['extendedIngredients'] != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Nguyên liệu chính:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ...List.generate(recipe['extendedIngredients'].length,
//                       (index) {
//                     final ingredient = recipe['extendedIngredients'][index];
//                     return Row(
//                       children: [
//                         if (ingredient['image'] != null)
//                           Image.network(
//                             'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}',
//                             width: 40,
//                             height: 40,
//                           ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                               '${ingredient['translated_original'] ?? 'N/A'}',
//                               style: const TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             const SizedBox(height: 16),
//             if (recipe['nutrition'] != null &&
//                 recipe['nutrition']['nutrients'] != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Thông tin dinh dưỡng:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ...List.generate(recipe['nutrition']['nutrients'].length,
//                       (index) {
//                     final nutrient = recipe['nutrition']['nutrients'][index];
//                     return Text(
//                       '- ${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
//                       style: const TextStyle(fontSize: 16),
//                     );
//                   }),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:assist_health/src/others/theme.dart';

class RecipeDetails extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetails({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  bool isSave = false;

  void saveRecipe(Map<String, dynamic> recipe) {
    // print('Món ăn đã được lưu: ${recipe['title_translated']}');
    // Thêm logic lưu món ăn vào cơ sở dữ liệu hoặc trạng thái
  }

  void unsaveRecipe(Map<String, dynamic> recipe) {
    // print('Món ăn đã bị xóa khỏi danh sách lưu: ${recipe['title_translated']}');
    // Thêm logic hủy lưu món ăn
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    print(recipe['introduce'][0]['steps']);
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title_translated'] ?? 'Chi tiết món ăn'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSave ? Icons.bookmark_added : Icons.bookmark_add_outlined,
              color: isSave ? Colors.yellow : Colors.white,
            ), // Biểu tượng thay đổi theo trạng thái
            tooltip: isSave ? 'Đã lưu món ăn' : 'Lưu món ăn',
            iconSize: 35,
            onPressed: () {
              setState(() {
                isSave = !isSave;
                if (isSave) {
                  saveRecipe(recipe); // Lưu món ăn
                } else {
                  unsaveRecipe(recipe); // Hủy lưu món ăn
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe['image'] != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    recipe['image'],
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              recipe['title_translated'] ?? 'Không có tiêu đề',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Id món ăn: ${recipe['id'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            Text(
                'Thời gian chuẩn bị: ${recipe['readyInMinutes'] ?? 'N/A'} phút',
                style: const TextStyle(fontSize: 16)),
            Text('Khẩu phần: ${recipe['servings'] ?? 'N/A'} khẩu phần',
                style: const TextStyle(fontSize: 16)),
            Text('Lượt thích: ${recipe['aggregateLikes'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            Text('Điểm sức khỏe: ${recipe['healthScore'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (recipe['diets'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chế độ ăn phù hợp:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(
                      height: 8), // Khoảng cách nhỏ giữa tiêu đề và chip
                  Wrap(
                    spacing: 8.0, // Khoảng cách ngang giữa các chip
                    runSpacing: 4.0, // Khoảng cách dọc giữa các dòng chip
                    children: List.generate(recipe['diets'].length, (index) {
                      return Chip(
                        label: Text(
                          recipe['diets'][index],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        backgroundColor: Colors.teal, // Màu nền chip
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (recipe['extendedIngredients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nguyên liệu chính:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...List.generate(recipe['extendedIngredients'].length,
                      (index) {
                    final ingredient = recipe['extendedIngredients'][index];
                    return Row(
                      children: [
                        if (ingredient['image'] != null)
                          Image.network(
                            'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}',
                            width: 40,
                            height: 40,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              '${ingredient['translated_original'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // ...List.generate(recipe['introduce'].length, (index) {
            //   final steps = recipe['introduce'][index]['steps'];
            //   print(steps);
            //   return Padding(
            //     padding: const EdgeInsets.only(bottom: 8.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: steps.map<Widget>((step) {
            //         return Padding(
            //           padding: const EdgeInsets.only(bottom: 8.0),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               // Hiển thị bước chế biến chính
            //               Text(
            //                 'Bước ${step['number']}: ${step['translated_step'] ?? step['step']}', // Sử dụng 'translated_step' nếu có
            //                 style: const TextStyle(fontSize: 16),
            //               ),
            //               const SizedBox(height: 4),
            //               // Nếu bước có các bước con, tiếp tục lặp qua và hiển thị các bước con
            //               // if (step['steps'] != null && step['steps'].isNotEmpty)
            //               //   Column(
            //               //     crossAxisAlignment: CrossAxisAlignment.start,
            //               //     children: step['steps'].map<Widget>((subStep) {
            //               //       return Padding(
            //               //         padding: const EdgeInsets.only(
            //               //             left: 16.0, bottom: 8.0),
            //               //         child: Column(
            //               //           crossAxisAlignment:
            //               //               CrossAxisAlignment.start,
            //               //           children: [
            //               //             // Hiển thị bước con
            //               //             Text(
            //               //               'Bước con ${subStep['number']}: ${subStep['translated_step'] ?? subStep['step']}',
            //               //               style: const TextStyle(fontSize: 14),
            //               //             ),
            //               //             const SizedBox(height: 4),
            //               //             // Hiển thị nguyên liệu nếu có
            //               //             if (subStep['ingredients'] != null &&
            //               //                 subStep['ingredients'].isNotEmpty)
            //               //               Column(
            //               //                 crossAxisAlignment:
            //               //                     CrossAxisAlignment.start,
            //               //                 children: [
            //               //                   const Text(
            //               //                     'Nguyên liệu:',
            //               //                     style: TextStyle(
            //               //                         fontSize: 12,
            //               //                         fontWeight: FontWeight.bold),
            //               //                   ),
            //               //                   ...List.generate(
            //               //                       subStep['ingredients'].length,
            //               //                       (ingredientIndex) {
            //               //                     final ingredient =
            //               //                         subStep['ingredients']
            //               //                             [ingredientIndex];
            //               //                     return Text(
            //               //                       '- ${ingredient['localizedName']}',
            //               //                       style: const TextStyle(
            //               //                           fontSize: 12),
            //               //                     );
            //               //                   }),
            //               //                 ],
            //               //               ),
            //               //             const SizedBox(height: 4),
            //               //             // Hiển thị thiết bị nếu có
            //               //             if (subStep['equipment'] != null &&
            //               //                 subStep['equipment'].isNotEmpty)
            //               //               Column(
            //               //                 crossAxisAlignment:
            //               //                     CrossAxisAlignment.start,
            //               //                 children: [
            //               //                   const Text(
            //               //                     'Thiết bị:',
            //               //                     style: TextStyle(
            //               //                         fontSize: 12,
            //               //                         fontWeight: FontWeight.bold),
            //               //                   ),
            //               //                   ...List.generate(
            //               //                       subStep['equipment'].length,
            //               //                       (equipmentIndex) {
            //               //                     final equipment =
            //               //                         subStep['equipment']
            //               //                             [equipmentIndex];
            //               //                     return Row(
            //               //                       children: [
            //               //                         if (equipment['image'] !=
            //               //                             null)
            //               //                           Image.network(
            //               //                             equipment['image'],
            //               //                             width: 40,
            //               //                             height: 40,
            //               //                           ),
            //               //                         const SizedBox(width: 8),
            //               //                         Text(
            //               //                           equipment['localizedName'],
            //               //                           style: const TextStyle(
            //               //                               fontSize: 12),
            //               //                         ),
            //               //                       ],
            //               //                     );
            //               //                   }),
            //               //                 ],
            //               //               ),
            //               //           ],
            //               //         ),
            //               //       );
            //               //     }).toList(),
            //               //   ),
            //             //   const SizedBox(height: 4),
            //             //   // Hiển thị nguyên liệu chính nếu có
            //             //   if (step['ingredients'] != null &&
            //             //       step['ingredients'].isNotEmpty)
            //             //     Column(
            //             //       crossAxisAlignment: CrossAxisAlignment.start,
            //             //       children: [
            //             //         const Text(
            //             //           'Nguyên liệu chính:',
            //             //           style: TextStyle(
            //             //               fontSize: 14,
            //             //               fontWeight: FontWeight.bold),
            //             //         ),
            //             //         ...List.generate(step['ingredients'].length,
            //             //             (ingredientIndex) {
            //             //           final ingredient =
            //             //               step['ingredients'][ingredientIndex];
            //             //           return Text(
            //             //             '- ${ingredient['localizedName']}',
            //             //             style: const TextStyle(fontSize: 14),
            //             //           );
            //             //         }),
            //             //       ],
            //             //     ),
            //             //   const SizedBox(height: 4),
            //             //   // Hiển thị thiết bị chính nếu có
            //             //   if (step['equipment'] != null &&
            //             //       step['equipment'].isNotEmpty)
            //             //     Column(
            //             //       crossAxisAlignment: CrossAxisAlignment.start,
            //             //       children: [
            //             //         const Text(
            //             //           'Thiết bị:',
            //             //           style: TextStyle(
            //             //               fontSize: 14,
            //             //               fontWeight: FontWeight.bold),
            //             //         ),
            //             //         ...List.generate(step['equipment'].length,
            //             //             (equipmentIndex) {
            //             //           final equipment =
            //             //               step['equipment'][equipmentIndex];
            //             //           return Row(
            //             //             children: [
            //             //               if (equipment['image'] != null)
            //             //                 Image.network(
            //             //                   equipment['image'],
            //             //                   width: 40,
            //             //                   height: 40,
            //             //                 ),
            //             //               const SizedBox(width: 8),
            //             //               Text(
            //             //                 equipment['localizedName'],
            //             //                 style: const TextStyle(fontSize: 14),
            //             //               ),
            //             //             ],
            //             //           );
            //             //         }),
            //             //       ],
            //             //     ),
            //             ],
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //   );
            // }),
            const Text(
              'Các bước nấu món này:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...List.generate(recipe['introduce'].length, (index) {
              final steps = recipe['introduce'][index]['steps'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                      steps.map<Widget>((step) {
                        if (step['translated_step'] == '') return SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị số bước và tên của bước chế biến
                              Text(
                                '- ${step['translated_step']}', // Sử dụng 'translated_step' nếu có, nếu không thì dùng 'step'
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              );
            }),
            const SizedBox(height: 16),
            if (recipe['nutrition'] != null &&
                recipe['nutrition']['nutrients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin dinh dưỡng:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...List.generate(recipe['nutrition']['nutrients'].length,
                      (index) {
                    final nutrient = recipe['nutrition']['nutrients'][index];
                    return Text(
                      '- ${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
                      style: const TextStyle(fontSize: 16),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
