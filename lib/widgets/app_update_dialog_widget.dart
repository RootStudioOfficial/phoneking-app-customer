import 'package:flutter/material.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialogWidget extends StatelessWidget {
  final bool isMandatory;
  final String message;
  final String storeUrl;

  const AppUpdateDialogWidget({
    super.key,
    required this.isMandatory,
    required this.message,
    required this.storeUrl,
  });

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isMandatory,
      child: AlertDialog(
        title: Text(isMandatory ? 'Update Required' : 'Update Available'),
        content: Text(message),
        actions: [
          if (!isMandatory)
            TextButton(
              onPressed: () {
               context.navigateBack();
              },
              child: const Text('Later'),
            ),
          TextButton(
            onPressed: () async {
              await _openStore();
              if (!isMandatory && context.mounted) {
                context.navigateBack();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
