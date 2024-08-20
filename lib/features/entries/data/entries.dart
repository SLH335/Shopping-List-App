import 'dart:convert';

import 'package:einkaufsliste/features/auth/data/auth.dart';
import 'package:http/http.dart' as http;
import 'package:einkaufsliste/features/entries/domain/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entries.g.dart';

@riverpod
class Entries extends _$Entries {
  @override
  Future<Map<String, List<Entry>>> build(String listId) async {
    final AuthData authData = await ref.watch(authProvider.future);
    final response = await http.get(
      Uri.http(authData.server, '/list/$listId'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    final json = jsonDecode(response.body);
    var entries = Entry.allFromJson(json['data'] ?? []);
    return entries;
  }

  Future<void> completeEntry(int id, bool completed) async {
    final AuthData authData = await ref.read(authProvider.future);
    final response = await http.post(
      Uri.http(authData.server, '/entry/$id/complete'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authData.token}',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'completed': completed.toString(),
      },
    );

    final json = jsonDecode(response.body);
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
    final response = await http.post(
      Uri.http(authData.server, '/entry'),
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

    final json = jsonDecode(response.body);

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
}
