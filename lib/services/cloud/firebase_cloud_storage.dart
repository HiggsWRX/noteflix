import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteflix/services/cloud/cloud_note.dart';
import 'package:noteflix/services/cloud/cloud_storage_constants.dart';
import 'package:noteflix/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final _notes = FirebaseFirestore.instance.collection('notes');

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await _notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final notes = _notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

    return notes;
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await _notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await _notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
