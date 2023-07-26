import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MultipleImagesPickerButton extends StatefulWidget {
  final void Function(List<dynamic> pickedImages) imagesPickFn;
  final List<dynamic>? alreadyPickedImages;

  const MultipleImagesPickerButton(this.imagesPickFn,
      {this.alreadyPickedImages = const <dynamic>[], super.key});

  @override
  State<MultipleImagesPickerButton> createState() =>
      _MultipleImagesPickerButtonState();
}

class _MultipleImagesPickerButtonState
    extends State<MultipleImagesPickerButton> {
  final picker = ImagePicker();

  Future _getImages() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    List<dynamic> newImages;
    if (pickedFiles.isNotEmpty) {
      newImages = List<dynamic>.from(
          pickedFiles.map((xfile) => File(xfile.path)).toList());
      if (widget.alreadyPickedImages!.isNotEmpty) {
        newImages.addAll(widget.alreadyPickedImages!);
      }
      widget.imagesPickFn(newImages);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image added.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 180,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _getImages,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Photos'),
            ),
          ),
        ],
      ),
    );
  }
}
