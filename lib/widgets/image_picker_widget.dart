import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final double radius;

  const ImagePickerWidget({super.key, required this.selectedImage, required this.onTap, this.radius = 48});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
            child:
                selectedImage == null
                    ? Icon(Icons.person, size: radius / 1.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))
                    : null,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
            child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
