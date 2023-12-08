import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  // Example mutable state
  bool isDrawerOpen = false;
  var userEmail = '';

  void getEmail() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedId = sharedPreferences.getString('userEmail');
    setState(() {
      userEmail = obtainedId!;
    });
  }

  @override
  void initState() {
    getEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("Drawer opened");
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 34, 4, 81),
                  Color.fromARGB(255, 133, 87, 211),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 18,
                ),
                Text(
                  // widget.userId,
                  userEmail,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.question_mark_rounded,
              size: 26,
            ),
            title: Text('FAQs & Support'),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: 26,
            ),
            onTap: () async {
              final SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.remove('userId');
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/base', // Replace with the route name for your login screen
                  (route) => false, // Remove all previous routes from the stack
                );
              }
            },
            title: Text('Log out'),
          ),
          // Example of state-dependent UI
          // ListTile(
          //   leading: const Icon(
          //     Icons.menu,
          //     size: 26,
          //   ),
          //   title: const Text('Toggle Drawer State'),
          //   onTap: () {
          //     setState(() {
          //       isDrawerOpen = !isDrawerOpen;
          //     });
          //   },
          // ),
          // if (isDrawerOpen)
          //   const ListTile(
          //     title: Text('Additional Drawer Content'),
          //     // Add your additional drawer content here
          //   ),
        ],
      ),
    );
  }
}
