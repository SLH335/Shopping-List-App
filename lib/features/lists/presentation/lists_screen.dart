import 'package:einkaufsliste/features/lists/data/lists.dart';
import 'package:einkaufsliste/features/lists/domain/list.dart';
import 'package:einkaufsliste/widgets/text_fields.dart';
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
    AsyncValue<List<ShoppingList>> lists = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufslisten'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context, ref),
        child: const Icon(Icons.add),
      ),
      body: switch (lists) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: ListView.builder(
                itemCount: value.length + 1,
                itemBuilder: (BuildContext context, int i) {
                  if (i == value.length) {
                    return const SizedBox(height: 72);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () {
                        context.goNamed(
                          'entries',
                          pathParameters: {'listId': value[i].id.toString()},
                          queryParameters: {'listName': value[i].name},
                        );
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

Future<void> _dialogBuilder(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController listNameController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: const Text('Einkaufsliste hinzufügen'),
          content: StandardField(
            controller: listNameController,
            label: 'Name',
            icon: const Icon(Icons.numbers_rounded),
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hinzufügen'),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                String name = listNameController.text.trim();
                ref.read(listsProvider.notifier).addList(name);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
