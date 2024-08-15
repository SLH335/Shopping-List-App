import 'package:einkaufsliste/features/auth/domain/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list.freezed.dart';
part 'list.g.dart';

@freezed
class ShoppingList with _$ShoppingList {
  factory ShoppingList({
    required int id,
    required String name,
    required User creator,
  }) = _ShoppingList;

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
}
