import 'dart:io';
import 'package:flutter/material.dart';

class FoodImagePickerCard extends StatelessWidget {
  final File? imageFile;

  const FoodImagePickerCard({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
        ),
      ),
      child: imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 44,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Snap or upload a food photo',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}
