import 'package:assist_health/src/widgets/loading_indicator.dart';
import 'package:assist_health/src/widgets/top_snackbar.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/other_screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passToggle = true;
  bool confirmPassToggle = true;
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message, Color color) {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    TopSnackBar.show(overlay, mediaQuery, message, color);
  }

  Future<String?> createAccount(
      String name, String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final now = DateTime.now();
      final formattedDate = "${now.day}-${now.month}-${now.year}";
      final docId = 'user_${formattedDate}_${userCredential.user!.uid}';

      // Create collection `users` and document with `docId`
      await firestore.collection('users').doc(docId).set({
        'name': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'imageURL': '',
        'role': 'user',
        'isOnline': false,
        'createdAt': now.toIso8601String(),
      });

      // Create subcollection `health_profiles` and document with `idDoc`
      await firestore
          .collection('users')
          .doc(docId)
          .collection('health_profiles')
          .doc('main_profile')
          .set({
        'name': name,
        'phone': '',
        'doB': '',
        'gender': '',
        'relationship': 'Tôi',
        'imageURL': '',
        'idDoc': 'main_profile',
        'idProfile': 'ID${DateTime.now().millisecondsSinceEpoch}',
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
      return "Đăng ký không thành công. Lỗi: $e";
    }
  }

  Future<void> handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin.", Colors.orange);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar("Email không hợp lệ.", Colors.red);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Mật khẩu không khớp.", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    final String? errorMessage = await createAccount(name, email, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (errorMessage == null) {
      _showSnackBar("Đăng ký thành công!", Colors.green);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showSnackBar(errorMessage, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Image.asset("assets/signup/signup.png"),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Họ và tên",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: const Text("Nhập mật khẩu"),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(passToggle
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill),
                          onPressed: () =>
                              setState(() => passToggle = !passToggle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: confirmPassToggle,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: const Text("Nhập lại mật khẩu"),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(confirmPassToggle
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill),
                          onPressed: () => setState(
                              () => confirmPassToggle = !confirmPassToggle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Themes.buttonClr,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black54,
                        elevation: 5,
                      ),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          LoadingIndicator(isLoading: isLoading),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
