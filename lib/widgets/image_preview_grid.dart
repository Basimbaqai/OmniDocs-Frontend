import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewGrid extends StatelessWidget {
  final List<File> images;
  final int crossAxisCount;

  const ImagePreviewGrid({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        return Image.file(images[index]);
      },
    );
  }
}
