import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? suffixIcon;
  final validator;
  final Widget prefixIcon;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final keyboardType;
  final bool enabled;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.prefixIcon,
      this.suffixIcon,
      required this.validator,
      required this.labelText,
      required this.hintText,
      required this.obscureText,
      required this.keyboardType,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      style: GoogleFonts.sourceCodePro(),
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        enabled: enabled,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        labelStyle: GoogleFonts.raleway(),
      ),
    );
  }
}
