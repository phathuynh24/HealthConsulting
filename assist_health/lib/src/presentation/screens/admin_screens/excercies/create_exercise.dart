import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  _ExerciseFormScreenState createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  late TextEditingController nameController;
  late TextEditingController caloController;
  late TextEditingController descController;
  late TextEditingController durationController;
  late TextEditingController imageUrlController;
  late TextEditingController youtubeController;

  List<Map<String, String>> dropdownPairs = [
    {'level': 'Cơ bản', 'muscleGroup': 'Bụng'}
  ];

  File? _imageFile;
  File? _videoFile;
  bool isYoutubeLink = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.exercise?.name ?? '');
    caloController =
        TextEditingController(text: widget.exercise?.calories.toString() ?? '');
    descController =
        TextEditingController(text: widget.exercise?.description ?? '');
    durationController =
        TextEditingController(text: widget.exercise?.duration.toString() ?? '');
    imageUrlController =
        TextEditingController(text: widget.exercise?.imageUrl ?? '');
    youtubeController =
        TextEditingController(text: widget.exercise?.youtubeUrl ?? '');

    if (widget.exercise != null) {
      dropdownPairs[0]['level'] =
          _extractLevel(widget.exercise!.types as String);
      dropdownPairs[0]['muscleGroup'] =
          _extractMuscleGroup(widget.exercise!.types as String);
    }
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        isYoutubeLink = false;
      });
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  String _generateTypeCode(String level, String group) {
    final levelCode =
        {'Cơ bản': '1', 'Trung bình': '2', 'Nâng cao': '3'}[level] ?? '1';
    final groupCode = {
          'Bụng': 'Abs',
          'Ngực': 'Chest',
          'Tay': 'Arm',
          'Chân': 'Leg'
        }[group] ??
        'Abs';
    return '$groupCode$levelCode';
  }

  String _extractLevel(String type) {
    if (type.endsWith('1')) return 'Cơ bản';
    if (type.endsWith('2')) return 'Trung bình';
    if (type.endsWith('3')) return 'Nâng cao';
    return 'Cơ bản';
  }

  String _extractMuscleGroup(String type) {
    if (type.startsWith('Abs')) return 'Bụng';
    if (type.startsWith('Chest')) return 'Ngực';
    if (type.startsWith('Arm')) return 'Tay';
    if (type.startsWith('Leg')) return 'Chân';
    return 'Bụng';
  }

  void _saveExercise() async {
    List<String> typeCodes = dropdownPairs
        .map((pair) => _generateTypeCode(pair['level']!, pair['muscleGroup']!))
        .toList();

    String? imageUrl = imageUrlController.text;
    String? videoUrl = youtubeController.text;

    // Upload image if selected
    if (_imageFile != null) {
      imageUrl = await _uploadFile(_imageFile!,
          'exercise_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    }

    // Upload video if selected
    if (_videoFile != null) {
      videoUrl = await _uploadFile(_videoFile!,
          'exercise_videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
    }

    final newExercise = {
      "name": nameController.text,
      "calories": double.tryParse(caloController.text) ?? 0.0,
      "description": descController.text,
      "duration": int.tryParse(durationController.text) ?? 0,
      "imageUrl": imageUrl ?? '',
      "youtubeUrl": videoUrl ?? '',
      "types": typeCodes,
    };

    try {
      if (widget.exercise == null) {
        // Add new exercise
        await FirebaseFirestore.instance
            .collection('exercises')
            .add(newExercise);
      } else {
        // Update existing exercise
        await FirebaseFirestore.instance
            .collection('exercises')
            .doc(widget.exercise!.id)
            .update(newExercise);
      }
      Navigator.pop(context, newExercise);
    } catch (e) {
      print("Lỗi khi lưu vào Firestore: $e");
    }
  }

  Widget _buildVideoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: const Text('Nhập link YouTube'),
                value: true,
                groupValue: isYoutubeLink,
                onChanged: (value) => setState(() => isYoutubeLink = true),
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: const Text('Tải lên video'),
                value: false,
                groupValue: isYoutubeLink,
                onChanged: (value) => setState(() => isYoutubeLink = false),
              ),
            ),
          ],
        ),
        if (isYoutubeLink)
          TextField(
            controller: youtubeController,
            decoration: const InputDecoration(labelText: 'Link YouTube'),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.video_library, color: Colors.red),
              title: const Text('Chọn video'),
              subtitle: _videoFile != null ? Text(_videoFile!.path) : null,
              trailing: ElevatedButton(
                onPressed: _pickVideo,
                child: const Text('Tải lên'),
              ),
            ),
          ),
      ],
    );
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

  Widget _buildDropdownPair(int index) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: dropdownPairs[index]['level'],
            decoration: const InputDecoration(labelText: 'Mức độ'),
            items: ['Cơ bản', 'Trung bình', 'Nâng cao'].map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: (value) {
              setState(() {
                dropdownPairs[index]['level'] = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: dropdownPairs[index]['muscleGroup'],
            decoration: const InputDecoration(labelText: 'Nhóm cơ'),
            items: ['Bụng', 'Ngực', 'Tay', 'Chân'].map((group) {
              return DropdownMenuItem(value: group, child: Text(group));
            }).toList(),
            onChanged: (value) {
              setState(() {
                dropdownPairs[index]['muscleGroup'] = value!;
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              dropdownPairs
                  .removeAt(index); // Xóa cặp dropdown tại vị trí index
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm mới bài tập',
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

              const SizedBox(height: 10),
              // Upload Image
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('Chọn ảnh'),
                  subtitle: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : null,
                  trailing: ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Tải lên'),
                  ),
                ),
              ),

              _buildVideoSection(),

              const SizedBox(height: 10),
              ...dropdownPairs.asMap().entries.map((entry) {
                int index = entry.key;
                return _buildDropdownPair(index);
              }).toList(),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    dropdownPairs
                        .add({'level': 'Cơ bản', 'muscleGroup': 'Bụng'});
                  });
                },
                child: const Text('Thêm loại'),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Lưu bài tập',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
