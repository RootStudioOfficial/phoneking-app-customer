
import 'package:flutter/material.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/easy_text_widget.dart';
import 'package:phone_king_customer/widgets/loading_dialog_widget.dart';

extension DialogExtensions on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: EasyTextWidget(text: message, textColor: Colors.white),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: EasyTextWidget(text: message, textColor: Colors.white),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(context: this, barrierDismissible: false, builder: (_) => const LoadingDialogWidget());
  }

  void hideLoadingDialog() {
    navigateBack();
  }
}
