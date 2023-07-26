import 'dart:io';
import 'package:flutter/material.dart';

import '../../../helpers/constants.dart';
import 'multiple_images_picker_button.dart';

class EditMultipleImagesGrid extends StatelessWidget {
  final List<dynamic>? apartmentImagesFiles;
  final Function(dynamic) openImage;
  final Function(dynamic) removeImage;
  final Function(List<dynamic>) pickedImages;
  final List<dynamic> oldImages;

  const EditMultipleImagesGrid({
    required this.apartmentImagesFiles,
    required this.oldImages,
    required this.openImage,
    required this.removeImage,
    required this.pickedImages,
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
                          if (apartmentImagesFiles![index] is String)
                            Image.network(
                              apartmentImagesFiles![index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          if (apartmentImagesFiles![index] is File)
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
        apartmentImagesFiles == null
            ? MultipleImagesPickerButton(pickedImages,
                alreadyPickedImages: oldImages)
            : MultipleImagesPickerButton(pickedImages,
                alreadyPickedImages: apartmentImagesFiles!),
      ],
    );
  }
}
