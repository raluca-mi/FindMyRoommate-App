import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../helpers/constants.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  final ImageProvider<Object> selectedImage;
  final bool editMode;

  const UserImagePicker(this.imagePickFn,
      {this.selectedImage = const AssetImage(Constants.avatarPlaceholderPath),
      this.editMode = true,
      super.key});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _pickImage(bool galleryMode) async {
    final pickedImageFile = await ImagePicker().pickImage(
        source: galleryMode
            ? ImageSource.gallery
            : ImageSource.camera); //, imageQuality: 50, maxWidth: 150
    if (pickedImageFile == null) {
      return;
    } else {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: MediaQuery.of(context).size.height * 0.08,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : widget.selectedImage,
          backgroundColor: const Color.fromARGB(135, 201, 201, 201),
        ),
        widget.editMode
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text(Constants.takePhotoButtonText),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text(Constants.choosePhotoButtonText),
                )
              ])
            : Container()
      ],
    );
  }
}
