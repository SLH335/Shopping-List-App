import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:einkaufsliste/features/entries/domain/entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entries.g.dart';

@riverpod
class Entries extends _$Entries {
  @override
  Future<Map<String, List<Entry>>> build(String token, String listId) async {
    final response = await http.get(
      Uri.http('10.0.2.2:9001', '/list/$listId'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
    );
    final json = jsonDecode(response.body);
    var entries = Entry.allFromJson(json['data'] ?? []);
    return entries;
  }

  Future<void> completeEntry(String token, int id, bool completed) async {
    final response = await http.post(
      Uri.http('10.0.2.2:9001', '/entry/$id/complete'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
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

  Future<void> addEntry(String token, String listId, String text, String category) async {
    final response = await http.post(
      Uri.http('10.0.2.2:9001', '/entry'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
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
