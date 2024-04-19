import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  double height;
  RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;

  CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validationRegEx,
    this.obscureText = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegEx.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
            hintText: hintText, border: const OutlineInputBorder()),
      ),
    );
  }
}
