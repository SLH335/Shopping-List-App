import 'package:einkaufsliste/features/auth/presentation/login_screen.dart';
import 'package:einkaufsliste/features/auth/presentation/register_screen.dart';
import 'package:einkaufsliste/features/entries/presentation/entries_screen.dart';
import 'package:einkaufsliste/features/lists/presentation/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        ],
      ),
    ],
  );

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
