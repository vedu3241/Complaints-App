import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logi_regi/pages/base.dart';
import 'package:logi_regi/pages/login_page.dart';
import 'package:logi_regi/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;
  User user = User();

  void setInputs(identifier, value) {
    if (identifier == 'Email') {
      user.email = value;
    } else {
      user.password = value;
    }
  }

  Future saveLogin() async {
    var res = await http.post(
      Uri.parse('http://192.168.0.103:8000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'email': user.email,
          'password': user.password,
        },
      ),
    );

    final responseData = jsonDecode(res.body);
    String message;
    if (res.statusCode == 200) {
      String userId = responseData['userId'];

      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("userId", userId);
      sharedPreferences.setString("userEmail", user.email);

      message = responseData['message'];

      if (context.mounted) {
        // Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            //once login take user to Base
            builder: (ctx) => const Base(),
          ),
        );
      }
    } else if (res.statusCode == 401) {
      message = responseData['message'];

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Incorrect email or password"),
            content: const Text(
                "The credentials you entered is incorrect. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      }
    }
  }

  Future saveRegister() async {
    var res = await http.post(
      // 10.0.2.2
      Uri.parse('http://192.168.0.103:8000/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'email': user.email,
          'password': user.password,
        },
      ),
    );
    if (res.statusCode == 200) {
      // Navigating to login page
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
              },
            ),
            content: const Text("Registered successfully"),
          ),
        );
      }
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const LoginOrRegister()),
        );
      }
    } else if (res.statusCode == 409) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Invalid email.."),
            content: const Text("Email already exists!Try another one."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Registration Failed.."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      }
    }
  }

  void tooglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: tooglePages,
        setInputs: setInputs,
        saveLogin: saveLogin,
      );
    } else {
      return RegisterPage(
        onTap: tooglePages,
        setInputs: setInputs,
        saveRegister: saveRegister,
      );
    }
  }
}
