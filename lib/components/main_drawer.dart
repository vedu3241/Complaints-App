import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromARGB(255, 34, 4, 81),
                Color.fromARGB(255, 133, 87, 211)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 18,
                ),
                Text(
                  "User name here..",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.report,
              size: 26,
            ),
            title: Text('Navigation'),
          )
        ],
      ),
    );
  }
}
