import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise.dart';

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
  late TextEditingController youtubeController;
  File? _selectedImage;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.exercise.name);
    caloController =
        TextEditingController(text: widget.exercise.calories.toString());
    descController = TextEditingController(text: widget.exercise.description);
    durationController =
        TextEditingController(text: widget.exercise.duration.toString());
    youtubeController = TextEditingController(text: widget.exercise.youtubeUrl);

    _initializeYoutubeController(widget.exercise.youtubeUrl);
  }

  void _initializeYoutubeController(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    caloController.dispose();
    descController.dispose();
    durationController.dispose();
    youtubeController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateExercise() async {
    String imageUrl = widget.exercise.imageUrl;
    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('exercise_images/${widget.exercise.id}.jpg');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL(); // Lấy URL ảnh mới
      } catch (e) {
        print('Lỗi khi upload hình: $e');
        return; // Không cập nhật nếu upload thất bại
      }
    }
    await FirebaseFirestore.instance
        .collection('exercises')
        .doc(widget.exercise.id)
        .update({
      'name': nameController.text,
      'calories': double.tryParse(caloController.text) ?? 0,
      'description': descController.text,
      'duration': int.tryParse(durationController.text) ?? 0,
      'youtubeUrl': youtubeController.text,
      'imageUrl': imageUrl,
    });
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, void Function(String)? onChanged}) {
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
          onChanged: onChanged,
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
          'Chi tiết bài tập',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateExercise,
          )
        ],
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
              _buildTextField('Video YouTube', youtubeController,
                  onChanged: (value) {
                setState(() {
                  _youtubeController
                      .load(YoutubePlayer.convertUrlToId(value) ?? '');
                });
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!,
                        height: 200, fit: BoxFit.cover)
                    : (widget.exercise.imageUrl.isNotEmpty
                        ? Image.network(widget.exercise.imageUrl,
                            height: 200, fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                size: 100, color: Colors.grey),
                          )),
              ),
              const SizedBox(height: 20),
              if (widget.exercise.youtubeUrl.isNotEmpty)
                YoutubePlayer(
                  controller: _youtubeController,
                  showVideoProgressIndicator: true,
                ),
              const SizedBox(height: 20),
              // Text('Loại: ${widget.exercise.types.join(', ')}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateExercise,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                  backgroundColor:
                      Themes.gradientDeepClr, // Đặt màu nền của nút
                  foregroundColor: Colors.white, // Đặt màu chữ của nút
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
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
