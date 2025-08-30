import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  const LocationField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
