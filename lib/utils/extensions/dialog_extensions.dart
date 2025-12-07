import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone_king_customer/data/vos/app_update_config_vo/app_update_config_vo.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/app_update_dialog_widget.dart';
import 'package:phone_king_customer/widgets/easy_text_widget.dart';
import 'package:phone_king_customer/widgets/loading_dialog_widget.dart';

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

  Future<int> _getSemanticVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    final version = info.version;

    final parts = version.split('.');
    final major = int.parse(parts[0]);
    final minor = int.parse(parts[1]);
    final patch = int.parse(parts[2]);

    return major * 100 + minor * 10 + patch;
  }

  Future<void> checkForUpdateAndShowDialog(AppUpdateConfigVO config) async {
    final currentVersionCode = await _getSemanticVersionCode();

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
