import 'package:einkaufsliste/features/auth/data/auth.dart';
import 'package:einkaufsliste/features/lists/data/lists.dart';
import 'package:einkaufsliste/features/lists/domain/list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthData> authData = ref.watch(authProvider);
    final token = authData.valueOrNull?.token ?? '';
    AsyncValue<List<ShoppingList>> lists = ref.watch(listsProvider(token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufslisten'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: switch (lists) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: ListView.builder(
                itemCount: value.length,
                itemBuilder: (BuildContext context, int i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () {
                        context.goNamed('entries',
                            pathParameters: {'listId': value[i].id.toString()},
                            queryParameters: {'listName': value[i].name});
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value[i].name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Erstellt von ${value[i].creator.username}',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
