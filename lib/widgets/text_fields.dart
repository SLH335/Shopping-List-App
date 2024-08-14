import 'package:flutter/material.dart';

class EntryAddField extends StatelessWidget {
  const EntryAddField({super.key, this.controller, this.label = 'Neu', this.onSubmitted});

  final TextEditingController? controller;
  final String label;
  final dynamic onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_rounded),
          onPressed: onSubmitted,
        ),
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Eingabe ist erforderlich';
        }
        return null;
      },
    );
  }
}
