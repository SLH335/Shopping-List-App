import 'package:flutter/material.dart';

class StandardField extends StatelessWidget {
  const StandardField({super.key, this.controller, required this.label, required this.icon});

  final TextEditingController? controller;
  final String label;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: icon,
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return '$label ist erforderlich';
        }
        return null;
      },
    );
  }
}

class URLField extends StatelessWidget {
  const URLField({super.key, this.controller, required this.label, required this.icon});

  final TextEditingController? controller;
  final String label;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: icon,
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return '$label ist erforderlich';
        }
        if (!(Uri.tryParse(value)?.hasAbsolutePath ?? false)) {
          return '$label ist keine valide URL';
        }
        return null;
      },
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, this.controller, this.label = 'Passwort', this.onChanged});

  final TextEditingController? controller;
  final String label;
  final dynamic onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _passwordObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _passwordObscured,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_passwordObscured ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() {
              _passwordObscured = !_passwordObscured;
            }),
          )),
      onChanged: widget.onChanged,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return '${widget.label} ist erforderlich';
        }
        return null;
      },
    );
  }
}

class PasswordConfirmationField extends StatefulWidget {
  const PasswordConfirmationField(
      {super.key,
      this.controller,
      this.passwordController,
      this.label = 'Passwort wiederholen',
      this.onChanged});

  final TextEditingController? controller;
  final TextEditingController? passwordController;
  final String label;
  final dynamic onChanged;

  @override
  State<PasswordConfirmationField> createState() => _PasswordConfirmationFieldState();
}

class _PasswordConfirmationFieldState extends State<PasswordConfirmationField> {
  bool _passwordObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _passwordObscured,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_passwordObscured ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() {
              _passwordObscured = !_passwordObscured;
            }),
          )),
      onChanged: widget.onChanged,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return '${widget.label} ist erforderlich';
        }
        if (value != widget.passwordController?.text) {
          return 'Das Passwort stimmt nicht überein';
        }
        return null;
      },
    );
  }
}

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
