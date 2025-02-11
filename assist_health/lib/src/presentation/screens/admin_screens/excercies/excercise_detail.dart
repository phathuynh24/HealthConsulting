import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController caloController;
  late TextEditingController descController;
  late TextEditingController durationController;
  late TextEditingController imageUrlController;
  late TextEditingController youtubeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.exercise.name);
    caloController =
        TextEditingController(text: widget.exercise.calories.toString());
    descController = TextEditingController(text: widget.exercise.description);
    durationController =
        TextEditingController(text: widget.exercise.duration.toString());
    imageUrlController = TextEditingController(text: widget.exercise.imageUrl);
    youtubeController = TextEditingController(text: widget.exercise.youtubeUrl);
  }

  @override
  void dispose() {
    nameController.dispose();
    caloController.dispose();
    descController.dispose();
    durationController.dispose();
    imageUrlController.dispose();
    youtubeController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          ' Chi tiết bài tập',
          style: TextStyle(fontSize: 20),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Tên bài tập', nameController),
              _buildTextField('Calo/giây', caloController, isNumber: true),
              _buildTextField('Mô tả', descController),
              _buildTextField('Thời gian (giây)', durationController,
                  isNumber: true),
              _buildTextField('Đường dẫn ảnh', imageUrlController),
              _buildTextField('Video YouTube', youtubeController),
              const SizedBox(height: 20),
              if (widget.exercise.imageUrl.isNotEmpty)
                Image.network(widget.exercise.imageUrl,
                    height: 200, fit: BoxFit.cover),
              const SizedBox(height: 20),
              if (widget.exercise.youtubeUrl.isNotEmpty)
                Text('Video: ${widget.exercise.youtubeUrl}'),
              const SizedBox(height: 20),
              Text('Loại: ${widget.exercise.types.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
