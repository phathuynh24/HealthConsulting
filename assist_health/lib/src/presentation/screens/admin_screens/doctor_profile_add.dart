// ignore_for_file: avoid_print

import 'dart:io';

import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({Key? key}) : super(key: key);

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _workplaceController = TextEditingController();
  TextEditingController _experiencetextController = TextEditingController();
  TextEditingController _studytextController = TextEditingController();
  File? _selectedImage;
  List<String> _selectedSpecialties = [];
  final List<String> _specialties = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn thương chỉnh hình",
    "Tim mạch",
    "Tiêu hóa",
    "Hô hấp",
    "Huyết học",
    "Nội tiết",
  ];
  final List<Experience> _experiences = [Experience()];
  final List<Education> _educations = [Education()];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
    _workplaceController = TextEditingController();
    _experiencetextController = TextEditingController();
    _studytextController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _workplaceController.dispose();
    _experiencetextController.dispose();
    _studytextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm Bác sĩ',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Themes.primaryColor,
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(_selectedImage!,
                                      fit: BoxFit.cover),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Themes.iconClr,
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên bác sĩ',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
              const SizedBox(height: 16),
              MultiSelectDialogField(
                items: _specialties
                    .map(
                        (String value) => MultiSelectItem<String>(value, value))
                    .toList(),
                initialValue: _selectedSpecialties,
                onConfirm: (values) {
                  setState(() {
                    _selectedSpecialties = values.cast<String>().toList();
                  });
                },
                title: const Text('Chuyên khoa'),
                dialogHeight: 300,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _workplaceController,
                decoration: const InputDecoration(
                  labelText: 'Nơi công tác',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Experience input for each entry
              for (int i = 0; i < _experiences.length; i++)
                _buildExperienceInput(i),
              const SizedBox(height: 16),
              TextField(
                controller: _experiencetextController,
                decoration: const InputDecoration(
                  labelText: 'Kinh nghiệm làm việc',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              // Education input for each entry
              for (int i = 0; i < _educations.length; i++)
                _buildEducationInput(i),
              const SizedBox(height: 16),
              TextField(
                controller: _studytextController,
                decoration: const InputDecoration(
                  labelText: 'Học vấn',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.gradientDeepClr,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _saveDataToFirestore,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Thêm',
                      style: TextStyle(fontSize: 20, color: Colors.white),
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

  Widget _buildExperienceInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kinh nghiệm làm việc'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _experiences[index].startYear,
                onChanged: (newValue) {
                  setState(() {
                    _experiences[index].startYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: const InputDecoration(
                  labelText: 'Bắt đầu',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Dropdown for end year
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _experiences[index].endYear,
                onChanged: (newValue) {
                  setState(() {
                    _experiences[index].endYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: const InputDecoration(
                  labelText: 'Kết thúc',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _experiences[index].workplaceController,
                decoration: const InputDecoration(
                  labelText: 'Nơi làm việc',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _addExperienceDescription(index);
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Học vấn'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _educations[index].startYear,
                onChanged: (newValue) {
                  setState(() {
                    _educations[index].startYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: const InputDecoration(
                  labelText: 'Bắt đầu',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Dropdown for end year
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _educations[index].endYear,
                onChanged: (newValue) {
                  setState(() {
                    _educations[index].endYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: const InputDecoration(
                  labelText: 'Kết thúc',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _educations[index].schoolController,
                decoration: const InputDecoration(
                  labelText: 'Trường học',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _addEducationDescription(index);
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _generateYearItems() {
    final List<String> years =
        List.generate(30, (index) => (2024 - index).toString());
    return years
        .map<DropdownMenuItem<String>>(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();
  }

  void _addExperienceDescription(int index) {
    final currentExperience = _experiences[index];

    // Tạo mô tả thời gian mới từ thông tin hiện tại
    String timelineDescription =
        '${currentExperience.startYear} - ${currentExperience.endYear}: ${currentExperience.workplaceController.text}';

    // Thêm mô tả thời gian mới vào danh sách trong Experience
    currentExperience.timelineDescriptions.add(timelineDescription);
    _experiencetextController.text =
        currentExperience.timelineDescriptions.join('\n');
  }

  void _addEducationDescription(int index) {
    final currentEducation = _educations[index];

    // Tạo mô tả học vấn mới từ thông tin hiện tại
    String educationDescription =
        '${currentEducation.startYear} - ${currentEducation.endYear}: ${currentEducation.schoolController.text}';

    // Thêm mô tả học vấn mới vào danh sách trong Education
    currentEducation.educationDescriptions.add(educationDescription);
    _studytextController.text =
        currentEducation.educationDescriptions.join('\n');
  }

  Future<String?> _uploadImageToFirebase(File imageFile, String uid) async {
    try {
      // Access Firebase Storage instance
      FirebaseStorage storage = FirebaseStorage.instance;

      // Create a reference to the image file
      Reference storageReference = storage.ref().child('images/$uid.jpg');

      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void _saveDataToFirestore() async {
    try {
      String uid = const Uuid().v4();
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String description = _descriptionController.text.trim();
      String workplace = _workplaceController.text.trim();
      // String experienceText = _experiencetextController.text.trim();
      // String studyTexT = _studytextController.text.trim();
      // Validate that all required fields are filled
      if (name.isEmpty ||
          email.isEmpty ||
          description.isEmpty ||
          workplace.isEmpty ||
          _selectedImage == null) {
        _showErrorSnackBar('Please fill in all fields and select an image.');
        return;
      }
      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
          .hasMatch(email)) {
        _showErrorSnackBar('Please enter a valid email address.');
        return;
      }
      if (_experiences.any((experience) =>
          experience.startYear.compareTo(experience.endYear) > 0)) {
        _showErrorSnackBar(
            'Start year must be before end year for experiences.');
        return;
      }
      if (_educations.any((education) =>
          education.startYear.compareTo(education.endYear) > 0)) {
        _showErrorSnackBar(
            'Start year must be before end year for educations.');
        return;
      }

      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if an account with the provided email already exists
      QuerySnapshot existingAccounts = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingAccounts.docs.isNotEmpty) {
        // An account with the same email already exists
        _showErrorSnackBar('An account with this email already exists.');
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: '123456',
      );

      // Create a new document in the 'users' collection with the generated UID
      DocumentReference doctorRef =
          firestore.collection('users').doc(userCredential.user!.uid);
      String? downloadURL;
      if (_selectedImage != null) {
        downloadURL = await _uploadImageToFirebase(_selectedImage!, uid);
      }

      // Set data for the doctor document
      await doctorRef.set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text,
        'email': email,
        'specialty': _selectedSpecialties,
        'role': 'doctor',
        'description': _descriptionController.text,
        'workplace': _workplaceController.text,
        'experienceText': _experiencetextController.text,
        'studyText': _studytextController.text,
        'experiences': _experiences
            .map((experience) => experience.timelineDescriptions)
            .expand((descriptions) => descriptions)
            .toList(),
        'educations': _educations
            .map((education) => education.educationDescriptions)
            .expand((descriptions) => descriptions)
            .toList(),
        'imageURL': downloadURL,
        'status': 'offline',
      });

      _showSuccessSnackBar('Doctor information saved successfully!');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      print('Error saving data to Firestore: $e');
      _showErrorSnackBar('Error saving data to Firestore');
    }
  }

  _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Customize the background color
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Customize the background color
      ),
    );
  }
}

class Experience {
  String startYear = '2020';
  String endYear = '2022';
  TextEditingController workplaceController = TextEditingController();
  List<String> timelineDescriptions = [];
}

class Education {
  String startYear = '2020';
  String endYear = '2022';
  TextEditingController schoolController = TextEditingController();
  List<String> educationDescriptions = [];
}
