import 'dart:io';

import 'package:flutter/material.dart';

import '../../../helpers/constants.dart';
import 'multiple_images_picker_button.dart';

class AddMultipleImagesGrid extends StatelessWidget {
  final List<dynamic>? apartmentImagesFiles;
  final Function(File) openImage;
  final Function(File) removeImage;
  final Function(List<dynamic>) pickedImages;

  const AddMultipleImagesGrid({
    required this.openImage,
    required this.removeImage,
    required this.pickedImages,
    this.apartmentImagesFiles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.height * 0.45,
          height: MediaQuery.of(context).size.height * 0.3,
          child: apartmentImagesFiles == null || apartmentImagesFiles!.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const Image(
                      image: AssetImage(Constants.apartmentPlaceholderPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : GridView.builder(
                  itemCount: apartmentImagesFiles!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        openImage(apartmentImagesFiles![index]);
                      },
                      child: Stack(
                        children: [
                          Image.file(
                            apartmentImagesFiles![index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                removeImage(apartmentImagesFiles![index]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(193, 214, 214, 214),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        apartmentImagesFiles == null || apartmentImagesFiles!.isEmpty
            ? MultipleImagesPickerButton(pickedImages)
            : MultipleImagesPickerButton(
                pickedImages,
                alreadyPickedImages: apartmentImagesFiles!,
              ),
      ],
    );
  }
}
