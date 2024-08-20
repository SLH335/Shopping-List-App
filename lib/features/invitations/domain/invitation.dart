import 'package:einkaufsliste/features/auth/domain/user.dart';
import 'package:einkaufsliste/features/lists/domain/list.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation.freezed.dart';
part 'invitation.g.dart';

@freezed
class Invitation with _$Invitation {
  factory Invitation({
    required String token,
    required User inviter,
    required User invitee,
    required ShoppingList list,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);
}