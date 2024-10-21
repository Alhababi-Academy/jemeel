// Importing the Material Design package for UI elements
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';
// Importing a custom widget for displaying a loading spinner

// Defining a stateless widget 'LoadingAlertDialog', a reusable UI component
class LoadingAlertDialog extends StatelessWidget {
  // A nullable String variable to hold the message that will be displayed in the dialog
  final String? message;
  // Constructor of the widget, allowing an optional message to be provided
  const LoadingAlertDialog({this.message});

  // Overriding the build method to describe the UI of the widget
  @override
  Widget build(BuildContext context) {
    // Returning an AlertDialog widget
    return AlertDialog(
      // The 'key' pxroperty isn't necessary here and can be removed for cleaner code
      key: key,
      // The content of the AlertDialog, structured in a Column for vertical layout
      content: Column(
        // Setting the mainAxisSize to min, so the column shrinks to fit the children
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Calling the circularProgress function from the imported loadingWidget
          // It is assumed to return a widget, likely a CircularProgressIndicator
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Jemeel.primraryColor,
              ),
            ),
          ),
          // A SizedBox for adding some vertical space
          const SizedBox(
            height: 10,
          ),
          // A Text widget displaying the message
          // Using the '!' operator as the message is nullable
          // This implies the message is expected to be non-null when used
          Text(message!),
        ],
      ),
    );
  }
}
