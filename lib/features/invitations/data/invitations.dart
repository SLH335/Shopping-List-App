import 'dart:convert';

import 'package:shoppinglist/features/auth/data/auth.dart';
import 'package:shoppinglist/features/invitations/domain/invitation.dart';
import 'package:shoppinglist/features/lists/data/lists.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitations.g.dart';

@riverpod
class Invitations extends _$Invitations {
  @override
  Future<List<Invitation>> build() async {
    final AuthData authData = await ref.watch(authProvider.future);
    Response response;
    try {
      response = await get(
        Uri.parse('${authData.server}/invitations'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
        },
      );
    } catch (e) {
      return [];
    }

    final json = jsonDecode(response.body);
    if (response.statusCode != 200) {
      print(json['message']);
    }
    final invitations = <Invitation>[];
    for (var invitationData in json['data']) {
      final invitation = Invitation.fromJson(invitationData);
      invitations.add(invitation);
    }
    return invitations;
  }

  Future<void> invite(String username, int listId) async {
    final AuthData authData = await ref.read(authProvider.future);
    Response response;
    try {
      response = await post(
        Uri.parse('${authData.server}/invitation'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'list_id': listId.toString(),
        },
      );
    } catch (e) {
      print(e);
      return;
    }

    final json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }
  }

  Future<void> acceptInvitation(String invitationToken) async {
    final AuthData authData = await ref.read(authProvider.future);
    Response response;
    try {
      response = await post(
        Uri.parse('${authData.server}/invitation/accept'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'invitation_token': invitationToken,
        },
      );
    } catch (e) {
      return;
    }

    final json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    final invitations = await future;
    invitations.removeWhere((element) => element.token == invitationToken);
    state = AsyncData(invitations);
    ref.invalidate(listsProvider);
  }

  Future<void> declineInvitation(String invitationToken) async {
    final AuthData authData = await ref.read(authProvider.future);
    Response response;
    try {
      response = await post(
        Uri.parse('${authData.server}/invitation/decline'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'invitation_token': invitationToken,
        },
      );
    } catch (e) {
      return;
    }

    final json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    final invitations = await future;
    invitations.removeWhere((element) => element.token == invitationToken);
    state = AsyncData(invitations);
  }

  Future<void> revokeInvitation(String invitationToken) async {
    final AuthData authData = await ref.read(authProvider.future);
    Response response;
    try {
      response = await post(
        Uri.parse('${authData.server}/invitation/revoke'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'invitation_token': invitationToken,
        },
      );
    } catch (e) {
      print(e);
      return;
    }

    final json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    final invitations = await future;
    invitations.removeWhere((element) => element.token == invitationToken);
    state = AsyncData(invitations);
  }
}
