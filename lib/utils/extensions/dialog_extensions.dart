import 'package:flutter/material.dart';
import 'package:phonekingcustomer/data/vos/app_update_config_vo/app_update_config_vo.dart';
import 'package:phonekingcustomer/utils/app_version.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:phonekingcustomer/widgets/app_update_dialog_widget.dart';
import 'package:phonekingcustomer/widgets/easy_text_widget.dart';
import 'package:phonekingcustomer/widgets/loading_dialog_widget.dart';

enum UpdateType { none, optional, mandatory }

extension DialogExtensions on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: EasyTextWidget(
          text: message,
          textColor: Colors.white,
          maxLines: 4,
        ),
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
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const LoadingDialogWidget(),
    );
  }

  void hideLoadingDialog() {
    navigateBack();
  }

  Future<void> checkForUpdateAndShowDialog(AppUpdateConfigVO config) async {
    final currentVersionCode = await AppVersionHelper.getCurrentVersionCode();

    final type = _getUpdateType(
      config: config,
      currentVersionCode: currentVersionCode,
    );

    if (!mounted) return;
    if (type == UpdateType.none) return;

    final isMandatory = type == UpdateType.mandatory;

    await showDialog(
      context: this,
      barrierDismissible: !isMandatory,
      builder: (_) => AppUpdateDialogWidget(
        isMandatory: isMandatory,
        message: config.updateMessage,
        storeUrl: config.storeUrl,
      ),
    );
  }

  UpdateType _getUpdateType({
    required AppUpdateConfigVO config,
    required int currentVersionCode,
  }) {
    if (config.mandatoryUpdate &&
        currentVersionCode < config.minimumVersionCode) {
      return UpdateType.mandatory;
    }

    if (config.optionalUpdateAvailable &&
        currentVersionCode < config.recommendedVersionCode) {
      return UpdateType.optional;
    }

    return UpdateType.none;
  }
}
