import 'package:flutter/material.dart';
import 'package:logi_regi/auth/login_or_register.dart';
import 'package:logi_regi/pages/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

var finalUserID = null;

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  State<Base> createState() => _Base();
}

class _Base extends State<Base> {
  //On restart app check the prefToken and on basis of that show required screen

  var activeScreen = 'login-regi';

  @override
  void initState() {
    getValidationData().whenComplete(() async {
      if (finalUserID == null) {
        setState(() {
          activeScreen = 'login-regi';
        });
      } else {
        setState(() {
          activeScreen = 'tab-screen';
        });
      }
    });
    super.initState();
  }

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedId = sharedPreferences.getString('userId');
    setState(() {
      finalUserID = obtainedId;
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget = const LoginOrRegister();
    if (activeScreen == 'tab-screen') {
      screenWidget = TabsScreen(
        userId: finalUserID,
      );
    }
    if (activeScreen == 'login-regi') {
      screenWidget = const LoginOrRegister();
    }
    return screenWidget;
  }
}
