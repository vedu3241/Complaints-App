import 'dart:convert';
// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:logi_regi/components/main_drawer.dart';
import 'package:logi_regi/components/single_report.dart';
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
  bool isData = true;
  bool isLoading = true; // Add loading indicator state

  void getReports() async {
    try {
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
        isLoading = false; // Data loading is complete
        reports = responseData['reports'];
        // print(reports);
        if (reports == null) {
          isData = false; // Update isData based on reports
          print(isData);
        }
        setState(() {});
      } else {
        print("Error: ${res.statusCode}");
        // You can also set isLoading to false in case of an error
        isLoading = false;
      }
    } catch (error) {
      print("Error: $error");
      isLoading = false;
    }
  }

  @override
  void initState() {
    print("in report screen");
    getReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget noData = const Center(
      child: Text(
        "No reports found..!",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
    );

    Widget loadingIndicator = const Center(
      child: CircularProgressIndicator(), // Add a loading indicator
    );

    Widget mainContent = ListView.builder(
      itemCount: reports?.length ?? 0, // Use null-aware operator
      itemBuilder: (context, int index) {
        return SingleReport(
          category: reports![index]['Category'],
          address: reports![index]['Address'],
          status: reports![index]['Status'],
          date: reports![index]['createdAt'],
        );
      },
    );

    return Scaffold(
      drawer: MainDrawer(userId: widget.userId),
      appBar: AppBar(
        title: const Text("My Reports"),
        backgroundColor: Color.fromARGB(255, 112, 49, 213),
        foregroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: () async {
              final SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.remove('userId');
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/base',
                  (route) => false,
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
      body: isLoading ? loadingIndicator : (isData ? mainContent : noData),
    );
  }
}
