import 'package:einkaufsliste/features/entries/data/entries.dart';
import 'package:einkaufsliste/features/entries/domain/entry.dart';
import 'package:einkaufsliste/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntriesScreen extends ConsumerStatefulWidget {
  const EntriesScreen({super.key, required this.listId, required this.listName});

  final String listId;
  final String listName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends ConsumerState<EntriesScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, List<Entry>>> entries = ref.watch(entriesProvider(widget.listId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context, ref, widget.listId),
        child: const Icon(Icons.add),
      ),
      body: switch (entries) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: ListView.builder(
              itemCount: value.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == value.length) {
                  return const SizedBox(height: 72);
                }
                final formKey = GlobalKey<FormState>();
                final TextEditingController addController = TextEditingController();

                return Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                value.keys.toList()[i],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const Divider(indent: 8, endIndent: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: value.values.toList()[i].length,
                            itemBuilder: (BuildContext context, int j) {
                              return ListTile(
                                leading: Checkbox(
                                  value: value.values.toList()[i][j].completed,
                                  onChanged: (checked) {
                                    ref.read(entriesProvider(widget.listId).notifier).completeEntry(
                                        value.values.toList()[i][j].id, checked ?? false);
                                  },
                                ),
                                title: Text(
                                  value.values.toList()[i][j].text,
                                  style: TextStyle(
                                      decoration: value.values.toList()[i][j].completed
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            title: EntryAddField(
                              controller: addController,
                              onSubmitted: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  ref.read(entriesProvider(widget.listId).notifier).addEntry(
                                      widget.listId,
                                      addController.text.trim(),
                                      value.keys.toList()[i]);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}

Future<void> _dialogBuilder(BuildContext context, WidgetRef ref, String listId) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController categoryNameController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: const Text('Kategorie hinzufügen'),
          content: StandardField(
            controller: categoryNameController,
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
                String name = categoryNameController.text.trim();
                ref.read(entriesProvider(listId).notifier).addCategory(name);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
