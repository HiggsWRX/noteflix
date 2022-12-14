import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:noteflix/services/crud/crud_constants.dart';

@immutable
class LocalUser with EquatableMixin {
  final int id;
  final String email;

  const LocalUser({
    required this.id,
    required this.email,
  });

  LocalUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, Email = $email';

  @override
  List<Object?> get props => [id];
}
