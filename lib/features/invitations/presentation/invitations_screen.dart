import 'package:shoppinglist/features/auth/data/auth.dart';
import 'package:shoppinglist/features/invitations/data/invitations.dart';
import 'package:shoppinglist/features/invitations/domain/invitation.dart';
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
    final AsyncValue<AuthData> authData = ref.watch(authProvider);
    final incomingInvitations = invitations.valueOrNull
            ?.where((element) => element.invitee.id == authData.valueOrNull?.user?.id)
            .toList() ??
        [];
    final outgoingInvitations = invitations.valueOrNull
            ?.where((element) => element.inviter.id == authData.valueOrNull?.user?.id)
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einladungen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(invitationsProvider.future),
        child: switch (invitations) {
          AsyncData(:final value) => Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: ListView.builder(
                  itemCount: value.length + 2,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == 0) {
                      if (incomingInvitations.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'Eingehende Einladungen',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                    if (i == incomingInvitations.length + 1) {
                      if (outgoingInvitations.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'Ausgehende Einladungen',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                    String title, subtitle;
                    dynamic action1, action2;
                    bool incoming = false;
                    if (i < incomingInvitations.length + 1) {
                      incoming = true;
                      int j = i - 1;
                      title = incomingInvitations[j].list.name;
                      subtitle = 'Eingeladen von ${incomingInvitations[j].inviter.username}';
                      action1 = () => ref
                          .read(invitationsProvider.notifier)
                          .acceptInvitation(incomingInvitations[j].token);
                      action2 = () => ref
                          .read(invitationsProvider.notifier)
                          .declineInvitation(incomingInvitations[j].token);
                    } else {
                      int j = i - incomingInvitations.length - 2;
                      title = outgoingInvitations[j].invitee.username;
                      subtitle = outgoingInvitations[j].list.name;
                      action2 = () => ref
                          .read(invitationsProvider.notifier)
                          .revokeInvitation(outgoingInvitations[j].token);
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (incoming)
                              IconButton(
                                onPressed: action1,
                                icon: const Icon(Icons.check),
                              ),
                            IconButton(
                              onPressed: action2,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          AsyncError(:final error) => Center(child: Text('Error: $error')),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}
