import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:forst_ui/core/failures/exceptions.dart';
import 'package:forst_ui/core/strings/constants.dart';
import 'package:forst_ui/core/utils/snack_bar_message.dart';
import 'package:forst_ui/features/auth/pages/sign_up.dart';
import 'package:forst_ui/features/auth/widgets/auth_btn.dart';
import 'package:forst_ui/features/report/pages/report_page.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(String email, String password) async {
    try {
      Response response = await post(Uri.parse(apiUrl + "/auth/authenticate"),
          body: jsonEncode({"email": email, "password": password}),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        for (var i = 0; i < 10; i++) {
          print("u r logged in");
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ReportScreen()));

        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);
      } else {
        SnackBarMessage().showErrorSnackBar(
            message: "Invalid credentials", context: context);
      }
    } catch (e) {
      throw LoginException();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is mandatory'; //dans le dossier Strings
              } else if (!isEmail(value)) {
                return "email Incorrect";
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
          const SizedBox(
            height: 50,
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 8) {
                return 'password is mandatory and more than 8 characters ';
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
          AuthButton(
            onPressed: () => {
              login(emailController.text.toString(),
                  passwordController.text.toString())
            },
            color: Colors.green,
            text: "Login",
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            child: const Text(
              "don t have an account? Sign up",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
