import 'package:flutter/material.dart';
import 'package:logi_regi/components/reportForm.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../components/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color.fromARGB(255, 255, 104, 35),
        foregroundColor: Colors.black,
        actions: [
          InkWell(
            onTap: () async {
              final SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.remove('userId');
              if (context.mounted) {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (ctx) => const Base(),
                //   ),
                // );

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/base', // Replace with the route name for your login screen
                  (route) => false, // Remove all previous routes from the stack
                );
              }
            },
            child: const Row(
              children: [
                Text(
                  "Log Out",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.logout),
                SizedBox(
                  width: 12,
                )
              ],
            ),
          ),
        ],
      ),
      drawer: MainDrawer(userId: userId),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ReportForm(userId: userId),
          ),
        ],
      ),
    );
  }
}
