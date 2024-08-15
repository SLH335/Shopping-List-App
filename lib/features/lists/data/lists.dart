import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:einkaufsliste/features/lists/domain/list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lists.g.dart';

@riverpod
class Lists extends _$Lists {
  @override
  Future<List<ShoppingList>> build(String token) async {
    final response = await http.get(
      Uri.http('10.0.2.2:9001', '/lists'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      print('\n\n\n${json['message']}\n\n\n');
    }
    final lists = <ShoppingList>[];
    for (var list in json['data']) {
      lists.add(ShoppingList.fromJson(list));
    }
    return lists;
  }
}