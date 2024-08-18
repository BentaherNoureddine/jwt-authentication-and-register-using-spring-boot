import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:forst_ui/core/utils/snack_bar_message.dart';
import 'package:forst_ui/features/admin/pages/admin_home_page.dart';
import 'package:forst_ui/features/auth/pages/sign_up.dart';
import 'package:forst_ui/features/auth/widgets/auth_btn.dart';
import 'package:forst_ui/features/report/pages/report_page.dart';

import '../../../core/strings/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl + "/auth/authenticate"),
        body: jsonEncode({"email": email, "password": password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        Map<String?, dynamic>? decodeJwt(String? token) {
          if (token == null) return null;
          try {
            final jwt = JWT.decode(token);
            return jwt.payload;
          } catch (e) {
            print("Error decoding JWT: $e");
            return null;
          }
        }

        final decodedToken = decodeJwt(token);
        final userAuthorities = decodedToken?['authorities'] ?? [];

        for(int i=0;i<10;i++){
          print(decodedToken?['authorities']);
        }

        final isAdmin = userAuthorities.contains("ADMIN");

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      } else {
        SnackBarMessage().showErrorSnackBar(
          message: "Invalid credentials",
          context: context,
        );
      }
    } catch (e) {
      print("Login error: $e");
      SnackBarMessage().showErrorSnackBar(
        message: "An error occurred. Please try again.",
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.brown,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is mandatory';
                } else if (!isEmail(value)) {
                  return "Invalid email address";
                }
                return null;
              },
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "Email",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 8) {
                  return 'Password is mandatory and must be at least 8 characters long';
                }
                return null;
              },
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: "Password",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AuthButton(
              onPressed: () => login(
                emailController.text,
                passwordController.text,
              ),
              color: Colors.green,
              text: "Login",
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text(
                "Don't have an account? Sign up",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
