import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({Key? key}) : super(key: key);

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<String> _specialties = [
    "Bệnh lý học",
    "Bệnh truyền nhiễm",
    "Bệnh nhiệt đới",
    "Chấn thương chỉnh hình",
    "Chỉnh hình nhi",
    "Chẩn đoán hình ảnh",
    "Da liễu",
    "Dinh dưỡng",
    "Dị ứng - Miễn dịch",
    "Gây mê hồi sức",
    "Hô hấp",
    "Huyết học",
    "Mắt",
    "Nam khoa",
    "Nha khoa",
    "Nhi khoa",
    "Nội thần kinh",
    "Nội tiết",
    "Nội tiết Nhi",
    "Ngoại tổng quát",
    "Phục hồi chức năng",
    "Sản phụ khoa",
    "Tay mũi họng",
    "Tai Mũi Họng Nhi",
    "Thần kinh",
    "Thần kinh ngoại biên",
    "Thận - Tiết niệu",
    "Thẩm mỹ",
    "Tim mạch",
    "Tiêu hóa",
    "Ung bướu",
    "Y học cổ truyền",
    "Y học thể thao",
  ];
  final List<String> _selectedSpecialties = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Thêm bác sĩ'),
            centerTitle: true,
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
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin cơ bản'),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Họ tên bác sĩ',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ tên bác sĩ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[a-zA-Z]{2,})')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Chuyên khoa'),
                  MultiSelectDialogField(
                    items:
                        _specialties.map((e) => MultiSelectItem(e, e)).toList(),
                    title: const Text('Chọn chuyên khoa'),
                    buttonText: const Text("Chọn chuyên khoa"),
                    initialValue: _selectedSpecialties,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 1.5,
                      ),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        _selectedSpecialties.clear();
                        _selectedSpecialties.addAll(values.cast<String>());
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Themes.gradientDeepClr,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                handleDoctorSignUp();
                              }
                            },
                      child: const Text(
                        'Thêm bác sĩ',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        LoadingIndicator(isLoading: _isLoading),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> handleDoctorSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    const password = "123456"; // Mật khẩu mặc định
    const role = "doctor"; // Vai trò của tài khoản

    if (name.isEmpty || email.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin.", Colors.orange);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar("Email không hợp lệ.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final String? errorMessage = await createDoctorAccount(
        name, email, password, role, _selectedSpecialties);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage == null) {
      _showSnackBar("Tài khoản bác sĩ đã được tạo thành công!", Colors.green);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      _showSnackBar(errorMessage, Colors.red);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<String?> createDoctorAccount(String name, String email,
      String password, String role, List<String> specialties) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'specialty': specialties,
        'isOnline': false,
        'isDeleted': false,
        'isFirstLogin': true,
        'createdAt': DateTime.now().toIso8601String(),
        'phone': '',
        'address': '',
        'careerTitiles': '',
        'consultingTime': 0,
        'description': '',
        'endTime': '',
        'experienceText': '',
        'groupdisease': [],
        'imageURL': '',
        'rating': 5,
        'serviceFee': 0,
        'startTime': '',
        'status': 'offline',
        'studyText': '',
        'workplace': ''
      });

      return null; // No error, success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "Email đã được sử dụng.";
        case 'weak-password':
          return "Mật khẩu quá yếu.";
        case 'invalid-email':
          return "Email không hợp lệ.";
        default:
          return "Đăng ký không thành công.";
      }
    } catch (e) {
      return "Không thể tạo tài khoản. Vui lòng thử lại.";
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
