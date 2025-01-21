import 'package:assist_health/src/presentation/screens/other_screens/sign_up.dart';
import 'package:assist_health/src/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:assist_health/src/widgets/admin_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assist_health/src/widgets/top_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool passToggle = true;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> resetPassword(String email) async {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);

    if (email.isEmpty) {
      TopSnackBar.show(overlay, mediaQuery,
          "Vui lòng nhập email để đặt lại mật khẩu.", Colors.orange);
      return;
    }
    if (!_isValidEmail(email)) {
      TopSnackBar.show(overlay, mediaQuery, "Email không hợp lệ.", Colors.red);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      TopSnackBar.show(overlay, mediaQuery,
          "Liên kết đặt lại mật khẩu đã được gửi.", Colors.green);
    } catch (error) {
      TopSnackBar.show(
          overlay, mediaQuery, "Đã xảy ra lỗi: $error", Colors.red);
    }
  }

  Future<void> handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);

    if (email.isEmpty && password.isEmpty) {
      TopSnackBar.show(overlay, mediaQuery, "Vui lòng nhập email và mật khẩu.",
          Colors.orange);
      return;
    }
    if (email.isEmpty) {
      TopSnackBar.show(
          overlay, mediaQuery, "Vui lòng nhập email.", Colors.orange);
      return;
    }
    if (!_isValidEmail(email)) {
      TopSnackBar.show(overlay, mediaQuery, "Email không hợp lệ.", Colors.red);
      return;
    }
    if (password.isEmpty) {
      TopSnackBar.show(
          overlay, mediaQuery, "Vui lòng nhập mật khẩu.", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = await logIn(email, password);

      if (user == null) {
        TopSnackBar.show(
            overlay, mediaQuery, "Đăng nhập không thành công!", Colors.red);
        return;
      }

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();
      String role = userDoc['role'] ?? '';

      if (!mounted) return;

      switch (role) {
        case 'user':
          TopSnackBar.show(
              overlay, mediaQuery, "Đăng nhập thành công!", Colors.green);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const UserNavBar()));
          break;
        case 'doctor':
          TopSnackBar.show(
              overlay, mediaQuery, "Đăng nhập thành công!", Colors.green);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const DoctorNavBar()));
          break;
        case 'admin':
          TopSnackBar.show(
              overlay, mediaQuery, "Đăng nhập thành công!", Colors.green);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminNavBar()));
          break;
        default:
          TopSnackBar.show(
              overlay, mediaQuery, "Vai trò không hợp lệ.", Colors.red);
      }

      await firestore
          .collection('users')
          .doc(user.uid)
          .update({'status': 'online'});
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Email không tồn tại.";
          break;
        case 'wrong-password':
          errorMessage = "Mật khẩu không chính xác.";
          break;
        case 'invalid-email':
          errorMessage = "Email không hợp lệ.";
          break;
        case 'invalid-credential':
          errorMessage = "Tài khoản hoặc mật khẩu không hợp lệ.";
          break;
        default:
          errorMessage = "Đăng nhập không thành công!";
      }
      TopSnackBar.show(overlay, mediaQuery, errorMessage, Colors.red);
    } catch (e) {
      TopSnackBar.show(overlay, mediaQuery, "Lỗi: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset("assets/login/login.png"),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "Mật khẩu",
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
                    ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
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
                        "Đăng nhập",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Chưa có tài khoản?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          ),
                          child: const Text(
                            "Đăng ký ngay!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Themes.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: InkWell(
                        onTap: () => resetPassword(_emailController.text),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(
                              color: Themes.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Indicator
          LoadingIndicator(isLoading: isLoading),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
