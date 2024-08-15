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
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    var entries = Entry.allFromJson(json['data']);
    return entries;
  }

  Future<void> completeEntry(String token, int id, bool completed) async {
    final response = await http.post(
      Uri.http('10.0.2.2:9001', '/entry/complete'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'id': id.toString(),
        'completed': completed.toString(),
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }
    var entries = Entry.allFromJson(json['data']);
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

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      print(json['message']);
      return;
    }
    var entries = Entry.allFromJson(json['data']);
    state = AsyncData(entries);
  }
}
