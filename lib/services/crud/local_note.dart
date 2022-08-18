import 'package:equatable/equatable.dart';
import 'package:noteflix/services/crud/crud_constants.dart';

class LocalNote with EquatableMixin {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const LocalNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  LocalNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1;

  @override
  String toString() =>
      'Note, ID = $id, User ID = $userId, Is Synced With Cloud = $isSyncedWithCloud, Text = $text';

  @override
  List<Object?> get props => [id];
}
