import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

Future<bool> showConfirmationDialog(
    BuildContext context, {
      required String title,
      required String message,
      String confirmText = 'Confirm',
      String cancelText = 'Cancel',
      bool isDestructive = false,
    }) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  ) ??
      false;
}
