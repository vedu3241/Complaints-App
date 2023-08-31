import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MytextField extends StatelessWidget {
  const MytextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.recordInput,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final void Function(String identifier, String input) recordInput;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) => {
        recordInput(hintText, value),
      },
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter something';
        }

        if (hintText == "Email") {
          if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          ).hasMatch(value)) {
            return null;
          } else {
            return 'Enter valid email';
          }
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
