// Importing the Material Design package for UI elements
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

// Defining a stateless widget 'ErrorAlertDialog' which is a reusable UI component
class ErrorAlertDialog extends StatelessWidget {
  // A String variable to hold the message that will be displayed in the dialog
  final String message;

  // Constructor of the widget, requiring a message to be provided when it's used
  const ErrorAlertDialog({required this.message});

  // Overriding the build method to describe the UI of the widget
  @override
  Widget build(BuildContext context) {
    // Returning an AlertDialog widget
    return AlertDialog(
      // The 'key' property isn't necessary here and can be removed for cleaner code
      key: key,
      // The content of the AlertDialog, which is a Text widget displaying the passed message
      content: Text(message),
      // A list of actions (buttons) that are placed at the bottom of the AlertDialog
      actions: <Widget>[
        // A container to hold the button, with its width set to the width of the screen
        Container(
          width: MediaQuery.of(context).size.width,
          // An ElevatedButton widget for the user to interact with
          child: ElevatedButton(
            // The function to execute when the button is pressed; here it closes the dialog
            onPressed: () {
              Navigator.pop(context);
            },
            // Styling for the button
            style: ButtonStyle(
              // The shape of the button, defined as a rounded rectangle

              // Background color of the button
              backgroundColor: MaterialStateProperty.all(
                const Color(0xffc8d2d3),
              ),
            ),
            // Padding inside the button surrounding the text
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: 16, // Font size of the text
                color: Jemeel.primraryColor, // Color of the text
              ),
            ),
          ),
        ),
      ],
    );
  }
}
