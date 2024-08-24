import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shoppinglist/features/auth/data/auth.dart';
import 'package:shoppinglist/features/auth/presentation/login_screen.dart';
import 'package:shoppinglist/features/auth/presentation/register_screen.dart';
import 'package:shoppinglist/features/entries/presentation/entries_screen.dart';
import 'package:shoppinglist/features/invitations/presentation/invitations_screen.dart';
import 'package:shoppinglist/features/lists/presentation/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _storage = const FlutterSecureStorage();

  final _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: 'lists',
        path: '/lists',
        builder: (context, state) => const ListsScreen(),
        routes: [
          GoRoute(
            name: 'entries',
            path: 'entries/:listId',
            builder: (context, state) => EntriesScreen(
              listId: state.pathParameters['listId'] ?? '',
              listName: state.uri.queryParameters['listName'] ?? '',
            ),
          ),
          GoRoute(
            name: 'invitations',
            path: 'invitations',
            builder: (context, state) => const InvitationsScreen(),
          ),
        ],
      ),
    ],
  );

  Future<void> _tryLogin() async {
    final server = await _storage.read(key: 'server');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    final token = await _storage.read(key: 'token');

    if (server != null && token != null) {
      await ref.read(authProvider.notifier).verifySession(server, token);
    } else if (server != null && username != null && password != null) {
      await ref.read(authProvider.notifier).login(server, username, password);
    }
  }

  @override
  void initState() {
    _tryLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Einkaufsliste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
