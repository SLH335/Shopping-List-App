import 'dart:convert';

import 'package:einkaufsliste/features/auth/data/auth.dart';
import 'package:http/http.dart' as http;
import 'package:einkaufsliste/features/lists/domain/list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lists.g.dart';

@riverpod
class Lists extends _$Lists {
  @override
  Future<List<ShoppingList>> build() async {
    final AuthData authData = await ref.watch(authProvider.future);
    http.Response response;
    try {
      response = await http.get(
        Uri.http(authData.server, '/lists'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
        },
      );
    } catch (e) {
      return [];
    }
    final json = jsonDecode(response.body);
    if (response.statusCode != 200) {
    }
    final lists = <ShoppingList>[];
    for (var list in json['data']) {
      lists.add(ShoppingList.fromJson(list));
    }
    return lists;
  }

  Future<void> addList(String name) async {
    final AuthData authData = await ref.read(authProvider.future);
    http.Response response;
    try {
      response = await http.post(
        Uri.http(authData.server, '/list'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${authData.token}',
        },
        body: {
          'name': name,
        }
      );
    } catch (e) {
      return;
    }
    final json = jsonDecode(response.body);
    if (response.statusCode != 200 || !json['success']) {
      return;
    }
    final list = ShoppingList.fromJson(json['data']);
    final previousState = await future;
    previousState.add(list);
    state = AsyncData(previousState);
  }
}
