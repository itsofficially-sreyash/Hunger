import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class CustomSnackbar extends StatelessWidget {
  final Color bgColor;
  final String title;
  final String message;
  final ContentType contentType;

  const CustomSnackbar({
    super.key,
    required this.bgColor,
    required this.title,
    required this.message,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: bgColor,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
  }
}
