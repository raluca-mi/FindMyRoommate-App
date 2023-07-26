import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import 'add_apartment_screen.dart';

class AddApartmentContainerScreen extends StatefulWidget {
  static const routeName = Constants.addApartmentScreenRoute;
  const AddApartmentContainerScreen({super.key});

  @override
  State<AddApartmentContainerScreen> createState() =>
      _AddApartmentContainerScreenState();
}

class _AddApartmentContainerScreenState
    extends State<AddApartmentContainerScreen> {
  List<dynamic> _apartmentImagesFiles = [];
  // ignore: prefer_final_fields
  GeoPoint? _apartmentCoordinates;
  String? _previewImageUrl;

  void _pickedImages(List<dynamic> images) {
    setState(() {
      _apartmentImagesFiles = images;
    });
  }

  void _removeImage(File image) {
    setState(() {
      _apartmentImagesFiles.remove(image);
    });
  }

  void _openImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Hero(
              tag: image.path,
              child: Image.file(image),
            ),
          ),
        ),
      ),
    );
  }

  void _selectPlace(double lat, double lng, String generatedPreviewImageUrl) {
    setState(() {
      _apartmentCoordinates = GeoPoint(lat, lng);
      _previewImageUrl = generatedPreviewImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AddApartmentScreen(
      apartmentImagesFiles: _apartmentImagesFiles,
      apartmentCoordinates: _apartmentCoordinates,
      previewImageUrl: _previewImageUrl,
      selectPlace: _selectPlace,
      pickedImages: _pickedImages,
      removeImage: _removeImage,
      openImage: _openImage,
    );
  }
}
