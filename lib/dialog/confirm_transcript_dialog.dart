import 'package:flutter/material.dart';

//FIXME: This is not used
class MyAlertDialog extends StatelessWidget {

 final Function onPressed;
  const MyAlertDialog(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Please Confirm'),
      content: const Text('Are you sure to remove the box?'),
      actions: [
        // The "Yes" button
        TextButton(
            onPressed: () {
              // Remove the box
              onPressed();
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Yes')),
        TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('No'))
      ],
    );
  }
}
