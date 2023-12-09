import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:logi_regi/components/report_form.dart';
import 'package:logi_regi/pages/info_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../components/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key, required this.userId, required this.changeIndex});
  final String userId;
  final Function changeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("LOGO"),
          ],
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 26, 25, 25),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const InfoScreen(),
              ));
            },
            child: const Icon(Icons.info_rounded),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      drawer: MainDrawer(userId: userId),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    // color: Color.fromARGB(255, 207, 201, 199),
                    ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Found Problem??",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                          color: Colors.orange),
                    ),
                    Text(
                      "Report us!!",
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            ),
            ReportForm(userId: userId, changeIndex: changeIndex),
          ],
        ),
      ),
    );
  }
}
