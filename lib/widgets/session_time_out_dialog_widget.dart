import 'package:flutter/material.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';

class SessionTimeoutDialog extends StatelessWidget {
  const SessionTimeoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restart_alt, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),

            const Text(
              "Session Timed Out",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your session has expired due to inactivity.\nPlease restart the session.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text("Restart Session"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.navigateBack();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
