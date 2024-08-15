import 'package:einkaufsliste/features/auth/data/auth.dart';
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
    final AsyncValue<AuthData> authData = ref.watch(authProvider);
    final token = authData.valueOrNull?.token ?? '';
    final AsyncValue<Map<String, List<Entry>>> entries =
        ref.watch(entriesProvider(token, widget.listId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: switch (entries) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int i) {
              final formKey = GlobalKey<FormState>();
              final TextEditingController addController = TextEditingController();

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
                                    .read(entriesProvider(token, widget.listId).notifier)
                                    .completeEntry(
                                        token, value.values.toList()[i][j].id, checked ?? false);
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
                              ref.read(entriesProvider(token, widget.listId).notifier).addEntry(
                                  token,
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
              );
            },
          ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
