import 'package:flutter/services.dart';
import 'package:shoppinglist/features/auth/data/auth.dart';
import 'package:shoppinglist/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    serverUrlController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthData> authData = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.valueOrNull?.state == AuthState.success) {
        context.go('/lists');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKey,
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 64, bottom: 24),
                child: Center(
                  child: Text(
                    'Registrieren',
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
                child: UsernameField(
                  controller: usernameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PasswordField(
                  controller: passwordController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PasswordConfirmationField(
                  controller: passwordConfirmationController,
                  passwordController: passwordController,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: const Text('Anmelden', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    TextInput.finishAutofillContext();
                    String serverUrl = serverUrlController.text.trim();
                    String username = usernameController.text.trim();
                    String password = passwordController.text.trim();

                    ref.read(authProvider.notifier).register(serverUrl, username, password);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: authData.when(
                    loading: () => const CircularProgressIndicator(),
                    data: (data) => switch (data.state) {
                      AuthState.initial => const Text(''),
                      AuthState.error => Text(
                          data.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      AuthState.success => const Text(
                          'Erfolgreich registriert',
                          style: TextStyle(color: Colors.green),
                        )
                    },
                    error: (error, stack) => Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Anmelden',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
