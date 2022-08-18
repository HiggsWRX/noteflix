import 'dart:async';
import 'package:noteflix/services/crud/crud_constants.dart';
import 'package:noteflix/services/crud/crud_exceptions.dart';
import 'package:noteflix/services/crud/local_note.dart';
import 'package:noteflix/services/crud/local_user.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteService {
  Database? _db;
  List<LocalNote> _notes = [];
  LocalUser? _user;

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _notesStreamController = StreamController<List<LocalNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NoteService() => _shared;

  late final StreamController<List<LocalNote>> _notesStreamController;
  Stream<List<LocalNote>> get allNotes => _notesStreamController.stream;

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
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();

    await db.close();
    _db = null;
  }

  Future<LocalUser> createUser({required String email}) async {
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

    return LocalUser(
      id: userId,
      email: email,
    );
  }

  Future<LocalUser> getUser({required String email}) async {
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

    return LocalUser.fromRow(results.first);
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

  Future<LocalNote> createNote({
    required LocalUser owner,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final localUser = await getUser(email: owner.email);

    if (localUser != owner) {
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

    final note = LocalNote(
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

  Future<LocalNote> getNote({
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

    final note = LocalNote.fromRow(results.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<Iterable<LocalNote>> getAllNotes() async {
    final currentUser = _user;

    if (currentUser == null) {
      throw UserShouldBeSetBeforeReadingAllNotesException;
    }

    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      noteTable,
      where: 'user_id = ?',
      whereArgs: [currentUser.id],
    );

    return results.map((row) => LocalNote.fromRow(row)).toList();
  }

  Future<LocalNote> updateNote({
    required LocalNote note,
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

  Future<LocalUser> getOrCreateUser(
      {required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);

      if (setAsCurrentUser) {
        _user = user;
      }

      return user;
    } on UserNotFoundException {
      final createdUser = await createUser(email: email);

      if (setAsCurrentUser) {
        _user = createdUser;
      }

      return createdUser;
    } catch (e) {
      rethrow;
    } finally {
      _cacheNotes();
    }
  }
}
