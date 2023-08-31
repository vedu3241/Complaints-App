import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class SingleReport extends StatelessWidget {
  const SingleReport({
    required this.category,
    required this.address,
    required this.status,
    required this.date,
  });

  final String category;
  final String address;
  final String status;
  final String date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color.fromARGB(255, 189, 160, 236),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(category), // Use category variable here
                  const Spacer(),
                  Text(formatter.format(DateTime.parse(date))),
                ],
              ),
              Text(address), // Use address variable here
              Text(status), // Use status variable here
            ],
          ),
        ),
      ),
    );
  }
}
