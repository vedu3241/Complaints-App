import 'dart:convert';
// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logi_regi/api_service.dart';
import 'package:logi_regi/components/main_drawer.dart';
import 'package:logi_regi/components/myReportTile.dart';
import 'package:logi_regi/components/single_report.dart';
import 'package:logi_regi/pages/info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String message = "message";

  void getReports() async {
    try {
      final Response res = await ApiService().getReports(widget.userId);
      final responseData = jsonDecode(res.body);
      print(res.statusCode);
      if (res.statusCode == 200) {
        setState(() {
          isLoading = false; // Data loading is complete
          reports = responseData['reports'];
        });
      } else if (res.statusCode == 401) {
        setState(() {
          isLoading = false;
          isData = false;
          message = "No reports at the moment..";
        });
      }
    } catch (error) {
      print("Get reports Error: $error");
      setState(() {
        isLoading = false;
        isData = false; // Set isData to false
        message = "Server error..";
      });
    }
  }

  final int timeoutDuration = 3000; // 10 seconds

  @override
  void initState() {
    print("in report screen");
    getReports();

    // Set a timeout for the loading
    // Future.delayed(Duration(milliseconds: timeoutDuration), () {
    //   if (isLoading) {
    //     // Loading is still ongoing after the timeout
    //     setState(() {
    //       isLoading = false; // Stop loading
    //       isData = false; // Set isData to false
    //       message = "Server error..";
    //     });
    //   }
    // });
    super.initState();
  }

  void refresh() {
    // refresh logic here...
  }

  @override
  Widget build(BuildContext context) {
    Widget noData = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );

    Widget loadingIndicator = const Center(
      child: CircularProgressIndicator(), // Add a loading indicator
    );

    Widget mainContent = ListView.builder(
      itemCount: reports?.length ?? 0, // Use null-aware operator
      itemBuilder: (context, int index) {
        return MyReportTile(
          category: reports![index]['Category'],
          address: reports![index]['Address'],
          status: reports![index]['Status'],
          date: reports![index]['createdAt'],
          description: reports![index]['Description'],
        );
      },
    );

    return Scaffold(
      drawer: MainDrawer(userId: widget.userId),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("LOGO"),
          ],
        ),
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
      body: isLoading ? loadingIndicator : (isData ? mainContent : noData),
    );
  }
}
