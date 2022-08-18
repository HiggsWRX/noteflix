import 'package:flutter/material.dart';
import 'package:noteflix/services/cloud/cloud_note.dart';
import 'package:noteflix/utils/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTapNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes.elementAt(index);
          return ListTile(
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onTapNote(note),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);

                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        });
  }
}
