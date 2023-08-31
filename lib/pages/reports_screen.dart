import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logi_regi/components/singleReport.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.userId});
  final String userId;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List? reports;

  void getReports() async {
    var res = await http.post(
      Uri.parse('http://192.168.0.103:8000/getReports'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, Object?>{
          'userId': widget.userId,
        },
      ),
    );
    final responseData = jsonDecode(res.body);
    if (res.statusCode == 200) {
      reports = responseData['reports'];
    }
    setState(() {});
  }

  @override
  void initState() {
    print("in report screen");
    getReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
        child: Text(
      "No reports found..!",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    ));

    //     if (reports) {
    //   mainContent = ReportList();
    // }`
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports"),
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
      body: reports == null
          ? null
          : ListView.builder(
              itemCount: reports!.length,
              itemBuilder: (context, int index) {
                return SingleReport(
                  category: reports![index]['Category'],
                  address: reports![index]['Address'],
                  status: reports![index]['Status'],
                  date: reports![index]['createdAt'],
                );
              },
            ),
      // body: mainContent,
    );
  }
}
