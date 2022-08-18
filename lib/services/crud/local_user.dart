import 'package:flutter/foundation.dart';
import 'package:noteflix/services/crud/crud_constants.dart';

@immutable
class LocalUser {
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
  bool operator ==(covariant LocalUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
