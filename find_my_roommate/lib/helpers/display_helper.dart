import 'package:flutter/material.dart';

class DisplayHelper {
  static showErrorMessage(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  static showSuccessMessage(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  }

  static showLoadingSpinner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
