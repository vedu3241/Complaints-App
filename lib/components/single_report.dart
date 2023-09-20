import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class SingleReport extends StatelessWidget {
  const SingleReport({
    super.key,
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
        color: const Color.fromARGB(255, 186, 164, 225),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ), // Use category variable here
                  const Spacer(),
                  Text(
                    formatter.format(DateTime.parse(date)),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 15),
              ), // Use address variable here
              const SizedBox(
                height: 8,
              ),
              Text("Status: $status"), // Use status variable here
            ],
          ),
        ),
      ),
    );
  }
}

//Idea: change color as per status of report red for pending and greeen when in progress