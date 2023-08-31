import 'package:flutter/material.dart';
import 'package:logi_regi/auth/login_or_register.dart';
import 'package:logi_regi/pages/base.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Base(),
      // initialRoute: '/base',
      routes: {
        '/base': (context) => const Base(),
        '/loginOrReg': (context) => const LoginOrRegister(),
        // Define more routes here
      },
    );
  }
}
