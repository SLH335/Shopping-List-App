import 'package:einkaufsliste/features/list/data/entries.dart';
import 'package:einkaufsliste/features/list/domain/entry.dart';
import 'package:einkaufsliste/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, List<Entry>>> entries =
        ref.watch(entriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: switch (entries) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int i) {
              final formKey = GlobalKey<FormState>();
              final TextEditingController addController =
                  TextEditingController();

              return Form(
                key: formKey,
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
                                ref
                                    .read(entriesProvider.notifier)
                                    .completeEntry(
                                        value.values.toList()[i][j].id,
                                        checked ?? false);
                              },
                            ),
                            title: Text(
                              value.values.toList()[i][j].text,
                              style: TextStyle(
                                  decoration:
                                      value.values.toList()[i][j].completed
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
                              ref.read(entriesProvider.notifier).addEntry(
                                  addController.text.trim(),
                                  value.keys.toList()[i]);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
