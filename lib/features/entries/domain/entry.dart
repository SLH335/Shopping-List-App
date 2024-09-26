import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class Entry with _$Entry {
  factory Entry({
    required int id,
    required int listId,
    required String text,
    required String category,
    required int orderIndex,
    required bool completed,
    required DateTime createdAt,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  static Map<String, List<Entry>> allFromJson(dynamic json) {
    List<Entry> entries = [];
    for (var element in json) {
      entries.add(Entry.fromJson(element));
    }
    Map<String, List<Entry>> categories = {};
    for (Entry entry in entries) {
      if (!categories.keys.contains(entry.category)) {
        categories[entry.category] = [entry];
      } else {
        categories[entry.category]?.add(entry);
      }
    }
    return categories;
  }
}