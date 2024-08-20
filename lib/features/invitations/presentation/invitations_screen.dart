import 'package:einkaufsliste/features/invitations/data/invitations.dart';
import 'package:einkaufsliste/features/invitations/domain/invitation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitationsScreen extends ConsumerStatefulWidget {
  const InvitationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends ConsumerState<InvitationsScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Invitation>> invitations = ref.watch(invitationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einladungen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: switch (invitations) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: ListView.builder(
              itemCount: value.length,
              itemBuilder: (BuildContext context, int i) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value[i].list.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Eingeladen von ${value[i].inviter.username}',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            ref.read(invitationsProvider.notifier).acceptInvitation(value[i].token);
                          },
                          icon: const Icon(Icons.check),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(invitationsProvider.notifier).declineInvitation(value[i].token);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
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
