import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showTextToast(String msg) {
  Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
}

void showTopRightToast(BuildContext context, String message) {
  final OverlayState overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20, // Below the status bar
      right: 20, // Right side of the screen
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green, // Change to your success color
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay
  overlayState.insert(overlayEntry);

  // Remove the toast after 3 seconds
  Future.delayed(const Duration(seconds: 3)).then((_) {
    overlayEntry.remove();
  });
}
