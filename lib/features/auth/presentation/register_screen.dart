import 'package:einkaufsliste/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    serverUrlController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 64, bottom: 24),
              child: Center(
                child: Text(
                  'Anmelden',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: URLField(
                controller: serverUrlController,
                label: 'Server',
                icon: const Icon(Icons.numbers_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: StandardField(
                controller: usernameController,
                label: 'Benutzername',
                icon: const Icon(Icons.person),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PasswordField(
                controller: passwordController,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                child: const Text('Anmelden', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    String serverUrl = serverUrlController.text.trim();
                    String username = usernameController.text.trim();
                    String password = passwordController.text.trim();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
