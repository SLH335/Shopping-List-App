import 'dart:convert';

import 'package:shoppinglist/features/auth/data/auth.dart';
import 'package:http/http.dart';
import 'package:shoppinglist/features/entries/domain/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entries.g.dart';

@riverpod
class Entries extends _$Entries {
  @override
  Future<Map<String, List<Entry>>> build(String listId) async {
    final AuthData authData = await ref.watch(authProvider.future);
    final response = await get(
      Uri.parse('${authData.server}/list/$listId'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    var entries = Entry.allFromJson(json['data'] ?? []);
    return entries;
  }

  Future<void> completeEntry(int id, bool completed) async {
    final AuthData authData = await ref.read(authProvider.future);
    final response = await post(
      Uri.parse('${authData.server}/entry/$id/complete'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authData.token}',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'completed': completed.toString(),
      },
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    var entry = Entry.fromJson(json['data']);
    final entries = await future;
    entries[entry.category]?.removeWhere((element) => element.id == entry.id);
    entries[entry.category]?.add(entry);
    entries[entry.category]?.sort((a, b) => a.createdAt.isBefore(b.createdAt) ? 0 : 1);

    state = AsyncData(entries);
  }

  Future<void> addEntry(String listId, String text, String category) async {
    final AuthData authData = await ref.read(authProvider.future);
    final response = await post(
      Uri.parse('${authData.server}/entry'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authData.token}',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'list_id': listId,
        'text': text,
        'category': category,
      },
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    var entry = Entry.fromJson(json['data']);
    final categories = await future;
    categories[entry.category]?.removeWhere((element) => element.id == entry.id);
    categories[entry.category]?.add(entry);

    state = AsyncData(categories);
  }

  Future<void> addCategory(String name) async {
    final categories = await future;
    categories[name] = [];

    state = AsyncData(categories);
  }

  Future<void> deleteEntry(int id) async {
    final AuthData authData = await ref.read(authProvider.future);
    final response = await delete(
      Uri.parse('${authData.server}/entry/$id'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
      encoding: Encoding.getByName('utf-8'),
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }

    final categories = await future;
    for (final category in categories.entries) {
      categories[category.key]?.removeWhere((element) => element.id == id);
    }

    state = AsyncData(categories);
  }
}
