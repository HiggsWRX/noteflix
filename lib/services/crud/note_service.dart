import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noteflix/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteService {
  Database? _db;
  List<DBNote> _notes = [];

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _notesStreamController = StreamController<List<DBNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NoteService() => _shared;

  late final StreamController<List<DBNote>> _notesStreamController;
  Stream<List<DBNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    }

    return db;
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    } catch (e) {
      rethrow;
    }
  }

  Future<void> open() async {
    final db = _db;
    if (db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final documentsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();

    await db.close();
    _db = null;
  }

  Future<DBUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(
      userTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );

    return DBUser(
      id: userId,
      email: email,
    );
  }

  Future<DBUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw UserNotFoundException();
    }

    return DBUser.fromRow(results.first);
  }

  /// Delete the user from the database.
  /// Parameters:
  ///  - email: The email of the user to delete.
  /// Throws [CouldNotDeleteUserException] if the user could not be deleted.
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DBNote> createNote({
    required DBUser owner,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    const text = '';
    final noteId = await db.insert(
      noteTable,
      {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      },
    );

    final note = DBNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({
    required int id,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfDeletions = await db.delete(
      noteTable,
    );

    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }

  Future<DBNote> getNote({
    required int id,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      throw NoteNotFoundException();
    }

    final note = DBNote.fromRow(results.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<Iterable<DBNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      noteTable,
    );

    return results.map((row) => DBNote.fromRow(row)).toList();
  }

  Future<DBNote> updateNote({
    required DBNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    }

    return await getNote(id: note.id);
  }

  Future<DBUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);

      return user;
    } on UserNotFoundException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }
}

@immutable
class DBUser {
  final int id;
  final String email;

  const DBUser({
    required this.id,
    required this.email,
  });

  DBUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, Email = $email';

  @override
  bool operator ==(covariant DBUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DBNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DBNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DBNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1;

  @override
  String toString() =>
      'Note, ID = $id, User ID = $userId, Is Synced With Cloud = $isSyncedWithCloud, Text = $text';

  @override
  bool operator ==(covariant DBNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"                    INTEGER NOT NULL,
        "user_id"               INTEGER NOT NULL,
        "text"                  TEXT,
        "is_synced_with_cloud"  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"    INTEGER NOT NULL,
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
