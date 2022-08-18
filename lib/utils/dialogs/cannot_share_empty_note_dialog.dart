import 'package:flutter/material.dart';
import 'package:noteflix/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Uhm...',
    content: 'You cannot share an empty note.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
