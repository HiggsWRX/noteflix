import 'package:flutter/material.dart';
import 'package:noteflix/services/auth/auth_service.dart';
import 'package:noteflix/services/cloud/cloud_note.dart';
import 'package:noteflix/services/cloud/firebase_cloud_storage.dart';
import 'package:noteflix/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:noteflix/utils/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;

      return widgetNote;
    }

    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final newNote =
        await _noteService.createNewNote(ownerUserId: currentUser.id);
    _note = newNote;

    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;

    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNotIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (text.isNotEmpty && note != null) {
      await _noteService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNotIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final text = _textController.text;

              if (_note == null || text.isEmpty) {
                return await showCannotShareEmptyNoteDialog(context);
              }

              return Share.share(text);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                  ),
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
