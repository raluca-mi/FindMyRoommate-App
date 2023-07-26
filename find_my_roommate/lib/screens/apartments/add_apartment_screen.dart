import 'dart:io';
import 'package:find_my_roommate/models/facility_chip.dart';
import 'package:find_my_roommate/widgets/pickers/facilities_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';
import '../../helpers/location_helper.dart';
import '../../models/apartment.dart';
import '../../providers/apartments_provider.dart';
import '../../widgets/customized/custom_button.dart';
import '../../widgets/pickers/location_picker.dart';
import '../../widgets/pickers/multiple_images/add_multiple_images_grid.dart';

class AddApartmentScreen extends StatefulWidget {
  final List<dynamic>? apartmentImagesFiles;
  final GeoPoint? apartmentCoordinates;
  final String? previewImageUrl;
  final Function(double, double, String) selectPlace;
  final Function(File) openImage;
  final Function(File) removeImage;
  final Function(List<dynamic>) pickedImages;

  const AddApartmentScreen(
      {required this.apartmentImagesFiles,
      required this.apartmentCoordinates,
      required this.selectPlace,
      required this.previewImageUrl,
      required this.pickedImages,
      required this.removeImage,
      required this.openImage,
      super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _form = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalCapacityController = TextEditingController();
  final _currentlyOccupiedByController = TextEditingController();

  var _isLoading = false;
  List<FacilityChip> _facilities = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _totalCapacityController.dispose();
    _currentlyOccupiedByController.dispose();

    super.dispose();
  }

  void _selectFacilities(List<FacilityChip> facilities) {
    _facilities = facilities;
  }

  Future<void> _uploadApartmentImages(List<dynamic> images) async {
    final Reference apartmentRef = FirebaseStorage.instance.ref().child(
        'apartment_images/${auth.FirebaseAuth.instance.currentUser!.uid}');

    for (int i = 0; i < images.length; i++) {
      final File imageFile = images[i];
      final String imageName =
          imageFile.path.split('/').last + DateTime.now().toString();
      final Reference imageRef = apartmentRef.child(imageName);

      try {
        await imageRef.putFile(imageFile);
      } catch (e) {
        DisplayHelper.showErrorMessage(
            context, 'Error uploading image $imageName: $e');
      }
    }
  }

  Future<List<String>> _downloadApartmentImageUrls() async {
    try {
      final Reference apartmentRef = FirebaseStorage.instance.ref().child(
          'apartment_images/${auth.FirebaseAuth.instance.currentUser!.uid}');
      final ListResult result = await apartmentRef.listAll();

      final List<String> imageUrls = [];

      for (final Reference ref in result.items) {
        final String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      DisplayHelper.showErrorMessage(
          context, 'Error downloading apartment images: $e');
      return [];
    }
  }

  Future<void> _addApartment(BuildContext context) async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (int.parse(_currentlyOccupiedByController.text.trim()) >
        int.parse(_totalCapacityController.text.trim())) {
      DisplayHelper.showErrorMessage(context,
          Constants.currentlyOccupiedByCannotBeGreaterThanTotalCapacityText);
      return;
    }
    if (_facilities.isEmpty) {
      DisplayHelper.showErrorMessage(
          context, Constants.pleaseSelectFacilitiesText);
      return;
    }

    _form.currentState!.save();

    final checkIsReserved = (int.parse(_totalCapacityController.text.trim()) ==
        int.parse(_currentlyOccupiedByController.text.trim()));

    setState(() {
      _isLoading = true;
    });

    if (widget.apartmentImagesFiles == null ||
        widget.apartmentImagesFiles!.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      DisplayHelper.showErrorMessage(context, Constants.pleaseUploadImageText);
      return;
    } else if (widget.apartmentCoordinates == null) {
      setState(() {
        _isLoading = false;
      });
      DisplayHelper.showErrorMessage(
          context, Constants.pleaseSelectLocationText);
      return;
    } else {
      try {
        //convert facilities to list of dynamic based on the FacilityEnum values
        final List<dynamic> selectedFacilities = [];
        for (FacilityChip facilityChip in _facilities) {
          selectedFacilities.add(facilityChip.label);
        }

        await _uploadApartmentImages(widget.apartmentImagesFiles!);
        final urls = await _downloadApartmentImageUrls();

        final newAddress = await LocationHelper.getPlaceAddress(
            widget.apartmentCoordinates!.latitude,
            widget.apartmentCoordinates!.longitude);

        final apartment = Apartment(
          id: '',
          ownerId: auth.FirebaseAuth.instance.currentUser!.uid,
          roommatesIds: [],
          title: _titleController.text.trim(),
          previewLocationImageUrl: widget.previewImageUrl!,
          address: newAddress,
          coordinates: GeoPoint(widget.apartmentCoordinates!.latitude,
              widget.apartmentCoordinates!.longitude),
          price: int.parse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          facilities: selectedFacilities,
          imageUrl: urls,
          createdAt: Timestamp.now(),
          lastModifiedAt: Timestamp.now(),
          totalCapacity: int.parse(_totalCapacityController.text.trim()),
          currentlyOccupiedBy:
              int.parse(_currentlyOccupiedByController.text.trim()),
          isReserved: checkIsReserved,
          isDisabled: false,
        );

        // ignore: use_build_context_synchronously
        Provider.of<ApartmentsProvider>(context, listen: false)
            .addApartment(apartment);

        setState(() {
          _isLoading = false;
        });

        // ignore: use_build_context_synchronously
        DisplayHelper.showSuccessMessage(
            context, Constants.apartmentAddedSuccessfullyText);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        DisplayHelper.showErrorMessage(context,
            '${Constants.apartmentAddedFailedText}: ${error.toString()}');
        Navigator.of(context).pop();
      }
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
            fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _verticalSpacer({int height = 15}) {
    return const SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.addApartmentAppBarText),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                children: [
                  _verticalSpacer(height: 20),
                  AddMultipleImagesGrid(
                    openImage: widget.openImage,
                    removeImage: widget.removeImage,
                    pickedImages: widget.pickedImages,
                    apartmentImagesFiles: widget.apartmentImagesFiles,
                  ),

                  _verticalSpacer(height: 20),
                  _label(Constants.titleLabel),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.home_filled),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: Constants.titleLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Constants.pleaseProvideTitleText;
                        }
                        return null;
                      },
                    ),
                  ),

                  _verticalSpacer(),
                  _label(Constants.locationLabel),
                  LocationPicker(widget.previewImageUrl, widget.selectPlace),

                  _verticalSpacer(),
                  _label(Constants.priceLabel),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.euro),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: Constants.priceLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        try {
                          int.tryParse(value!);
                          if (value.isEmpty) {
                            return Constants.pleaseProvidePriceText;
                          } else if (int.parse(value).isNegative ||
                              int.tryParse(value) == 0) {
                            return Constants.pleaseProvideValidPriceText;
                          }
                          return null;
                        } catch (e) {
                          return Constants.pleaseProvideValidPriceText;
                        }
                      },
                    ),
                  ),

                  _verticalSpacer(),
                  _label(Constants.totalCapacityLabel),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _totalCapacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: Constants.totalCapacityLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Constants.pleaseProvideValueText;
                        } else if (int.tryParse(value) == null) {
                          return Constants.pleaseProvideValidNumberText;
                        }
                        return null;
                      },
                    ),
                  ),

                  _verticalSpacer(),
                  _label(Constants.currentlyOcupiedLabel),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _currentlyOccupiedByController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: Constants.currentlyOcupiedLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Constants.pleaseProvideValueText;
                        } else if (int.tryParse(value) == null) {
                          return Constants.pleaseProvideValidNumberText;
                        }
                        return null;
                      },
                    ),
                  ),

                  _verticalSpacer(),
                  _label(Constants.descriptionLabel),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: Constants.descriptionLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Constants.pleaseProvideDescriptionText;
                        }
                        return null;
                      },
                    ),
                  ),

                  //facilities
                  FacilitiesPicker(
                      initialFacilities: _facilities,
                      onSave: _selectFacilities),

                  _verticalSpacer(height: 50),
                  CustomButton(
                      onTap: () => _addApartment(context),
                      text: Constants.addApartmentButtonText),
                  _verticalSpacer(),
                ],
              ),
            ),
    );
  }
}
