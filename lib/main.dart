import 'package:einkaufsliste/features/auth/presentation/login_screen.dart';
import 'package:einkaufsliste/features/auth/presentation/register_screen.dart';
import 'package:einkaufsliste/features/list/presentation/list_screen.dart';
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
    initialLocation: '/list',
    routes: [
      GoRoute(
        path: '/list',
        builder: (context, state) => const ListScreen(),
      )
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