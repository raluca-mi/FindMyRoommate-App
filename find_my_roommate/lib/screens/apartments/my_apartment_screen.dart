import 'dart:io';
import 'package:find_my_roommate/models/facility_chip.dart';
import 'package:find_my_roommate/screens/apartments/add_apartment_container_screen.dart';
import 'package:find_my_roommate/widgets/apartment/page_view_gallery.dart';
import 'package:find_my_roommate/widgets/charts/requests_chart.dart';
import 'package:find_my_roommate/widgets/customized/custom_edit_field.dart';
import 'package:find_my_roommate/widgets/pickers/facilities_picker.dart';
import 'package:find_my_roommate/widgets/pickers/location_picker.dart';
import 'package:find_my_roommate/widgets/pickers/multiple_images/edit_multiple_images_grid.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../helpers/display_helper.dart';
import '../../helpers/constants.dart';
import '../../helpers/enums/facility_enum.dart';
import '../../helpers/location_helper.dart';
import '../../models/apartment.dart';
import '../../widgets/customized/custom_button.dart';
import '../../providers/apartments_provider.dart';

class MyApartmentScreen extends StatefulWidget {
  final Apartment? oldApartment;
  final Function toggleDisabledStatus;
  final Function refreshApartment;
  const MyApartmentScreen(
      {required this.oldApartment,
      required this.toggleDisabledStatus,
      required this.refreshApartment,
      super.key});

  @override
  State<MyApartmentScreen> createState() => _MyApartmentScreenState();
}

class _MyApartmentScreenState extends State<MyApartmentScreen> {
  bool _isInEditMode = false;
  Map? editedApartment;

  final _form = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalCapacityController = TextEditingController();
  final _currentlyOccupiedByController = TextEditingController();
  final TextEditingController _facilityController = TextEditingController();

  var _isLoading = false;
  List<dynamic>? _facilities;
  GeoPoint? _coordinates;
  BuildContext? _savedContext;
  String? _previewLocationImageUrl;

  @override
  void initState() {
    if (widget.oldApartment == null) {
      editedApartment = null;
    } else {
      editedApartment = {
        'id': widget.oldApartment!.id,
        'ownerId': widget.oldApartment!.ownerId,
        'roommatesIds': widget.oldApartment!.roommatesIds,
        'title': widget.oldApartment!.title,
        'price': widget.oldApartment!.price,
        'address': widget.oldApartment!.address,
        'coordinates': widget.oldApartment!.coordinates,
        'facilities': widget.oldApartment!.facilities,
        'description': widget.oldApartment!.description,
        'imageUrl': widget.oldApartment!.imageUrl,
        'createdAt': widget.oldApartment!.createdAt,
        'lastModifiedAt': widget.oldApartment!.lastModifiedAt,
        'totalCapacity': widget.oldApartment!.totalCapacity,
        'currentlyOccupiedBy': widget.oldApartment!.currentlyOccupiedBy,
        'isReserved': widget.oldApartment!.isReserved,
        'isDisabled': widget.oldApartment!.isDisabled,
      };
      _titleController.text = widget.oldApartment!.title;
      _locationController.text = widget.oldApartment!.address;
      _priceController.text = widget.oldApartment!.price.toString();
      _descriptionController.text = widget.oldApartment!.description;
      _totalCapacityController.text =
          widget.oldApartment!.totalCapacity.toString();
      _currentlyOccupiedByController.text =
          widget.oldApartment!.currentlyOccupiedBy.toString();
      _facilities = widget.oldApartment!.facilities;
      _coordinates = widget.oldApartment!.coordinates;
      _previewLocationImageUrl = widget.oldApartment!.previewLocationImageUrl;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    editedApartment = {
      'id': widget.oldApartment!.id,
      'ownerId': widget.oldApartment!.ownerId,
      'roommatesIds': widget.oldApartment!.roommatesIds,
      'title': widget.oldApartment!.title,
      'price': widget.oldApartment!.price,
      'address': widget.oldApartment!.address,
      'coordinates': widget.oldApartment!.coordinates,
      'facilities': widget.oldApartment!.facilities,
      'description': widget.oldApartment!.description,
      'imageUrl': widget.oldApartment!.imageUrl,
      'createdAt': widget.oldApartment!.createdAt,
      'lastModifiedAt': widget.oldApartment!.lastModifiedAt,
      'totalCapacity': widget.oldApartment!.totalCapacity,
      'currentlyOccupiedBy': widget.oldApartment!.currentlyOccupiedBy,
      'isReserved': widget.oldApartment!.isReserved,
      'isDisabled': widget.oldApartment!.isDisabled,
    };
    _facilities = widget.oldApartment!.facilities;
    _coordinates = widget.oldApartment!.coordinates;
    _previewLocationImageUrl = widget.oldApartment!.previewLocationImageUrl;
    _savedContext = context;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _facilityController.dispose();
    _totalCapacityController.dispose();
    _currentlyOccupiedByController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isInEditMode = !_isInEditMode;
    });
    if (!_isInEditMode) {
      widget.refreshApartment();
    }
  }

  Future<List<String>> _getOldListOfImagesUrls() async {
    List<String> oldListOfUrls = [];
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(widget.oldApartment!.id)
        .get()
        .then((value) async {
      final imageUrlList = value.get('imageUrl');
      for (var item in imageUrlList) {
        if (item is String) {
          oldListOfUrls.add(item);
        }
      }
    });
    return oldListOfUrls;
  }

  Future<void> _editApartment(BuildContext savedContext) async {
    final List<String> oldListOfUrls;
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
    _form.currentState!.save();

    final checkIsReserved = (int.parse(_totalCapacityController.text.trim()) ==
        int.parse(_currentlyOccupiedByController.text.trim()));

    setState(() {
      _isLoading = true;
    });

    if (editedApartment!['imageUrl'].isEmpty) {
      setState(() {
        _isLoading = false;
      });
      DisplayHelper.showErrorMessage(context, Constants.noImageSelectedText);
      return;
    }

    if (widget.oldApartment!.id != '') {
      if (editedApartment!['imageUrl'] != null) {
        try {
          final urls = <dynamic>[];
          oldListOfUrls = await _getOldListOfImagesUrls();

          //delete from storage all images that are not in the new list
          for (var item in oldListOfUrls) {
            if (!editedApartment!['imageUrl'].contains(item)) {
              await FirebaseStorage.instance.refFromURL(item).delete();
            }
          }

          for (var item in editedApartment!['imageUrl']) {
            if (item is File) {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child(Constants.apartmentImagesBucket)
                  .child(widget.oldApartment!.ownerId)
                  .child(item.path.split('/').last + DateTime.now().toString());
              await ref.putFile(item);
              final url = await ref.getDownloadURL();
              urls.add(url);
            }
            if (item is String) {
              urls.add(item);
            }
          }

          final newAddress = await LocationHelper.getPlaceAddress(
              _coordinates!.latitude, _coordinates!.longitude);

          final updatedApartment = Apartment(
            id: widget.oldApartment!.id,
            imageUrl: urls,
            ownerId: widget.oldApartment!.ownerId,
            roommatesIds: widget.oldApartment!.roommatesIds,
            title: _titleController.text.trim(),
            previewLocationImageUrl: _previewLocationImageUrl!,
            address: newAddress,
            coordinates:
                GeoPoint(_coordinates!.latitude, _coordinates!.longitude),
            price: int.parse(_priceController.text.trim()),
            description: _descriptionController.text.trim(),
            facilities: _facilities!,
            createdAt: widget.oldApartment!.createdAt,
            lastModifiedAt: Timestamp.now(),
            totalCapacity: int.parse(_totalCapacityController.text.trim()),
            currentlyOccupiedBy:
                int.parse(_currentlyOccupiedByController.text.trim()),
            isReserved: checkIsReserved,
          );

          // ignore: use_build_context_synchronously
          await Provider.of<ApartmentsProvider>(savedContext, listen: false)
              .updateApartment(updatedApartment.id, updatedApartment);
          setState(() {
            _isLoading = false;
            _isInEditMode = false;
          });
          widget.refreshApartment();
          // ignore: use_build_context_synchronously
          DisplayHelper.showSuccessMessage(
              context, Constants.apartmentUpdatedSuccessfullyText);
        } on FirebaseException catch (e) {
          setState(() {
            _isLoading = false;
            _isInEditMode = false;
          });
          DisplayHelper.showErrorMessage(savedContext,
              '${Constants.errorUploadingImageText}: ${e.message}');
        } catch (e) {
          setState(() {
            _isLoading = false;
            _isInEditMode = false;
          });
          DisplayHelper.showErrorMessage(
              savedContext, Constants.errorUploadingImageText);
        }
      } else {
        final newAddress = await LocationHelper.getPlaceAddress(
            _coordinates!.latitude, _coordinates!.longitude);
        final apartment = Apartment(
          id: widget.oldApartment!.id,
          imageUrl: widget.oldApartment!.imageUrl,
          ownerId: widget.oldApartment!.ownerId,
          roommatesIds: widget.oldApartment!.roommatesIds,
          title: _titleController.text.trim(),
          previewLocationImageUrl: _previewLocationImageUrl!,
          address: newAddress,
          coordinates:
              GeoPoint(_coordinates!.latitude, _coordinates!.longitude),
          price: int.parse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          facilities: _facilities!,
          createdAt: widget.oldApartment!.createdAt,
          lastModifiedAt: Timestamp.now(),
          totalCapacity: int.parse(_totalCapacityController.text.trim()),
          currentlyOccupiedBy:
              int.parse(_currentlyOccupiedByController.text.trim()),
          isReserved: checkIsReserved,
        );

        // ignore: use_build_context_synchronously
        await Provider.of<ApartmentsProvider>(savedContext, listen: false)
            .updateApartment(apartment.id, apartment);
        setState(() {
          _isLoading = false;
          _isInEditMode = false;
        });
        widget.refreshApartment();
        // ignore: use_build_context_synchronously
        DisplayHelper.showSuccessMessage(
            context, Constants.apartmentUpdatedSuccessfullyText);
      }
    }
  }

  Widget _verticalSpacer({int height = 15}) {
    return const SizedBox(
      height: 20,
    );
  }

  Widget _buildAppBarIconButton(BuildContext context) {
    return _isInEditMode
        ? Row(
            children: [
              IconButton(
                onPressed: () => widget.toggleDisabledStatus(),
                icon: Icon(
                    widget.oldApartment!.isDisabled
                        ? Icons.lock
                        : Icons.lock_open_outlined,
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
              IconButton(
                onPressed: _toggleEditMode,
                icon: Icon(_isInEditMode ? Icons.close : Icons.edit),
              ),
            ],
          )
        : IconButton(
            onPressed: _toggleEditMode,
            icon: Icon(_isInEditMode ? Icons.close : Icons.edit),
          );
  }

  void _pickedImages(List<dynamic> images) {
    setState(() {
      editedApartment!['imageUrl'] = images;
    });
  }

  void _removeImage(dynamic image) {
    setState(() {
      editedApartment!['imageUrl'].remove(image);
    });
  }

  void _openImage(dynamic image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Hero(
              tag: image,
              child: image is String ? Image.network(image) : Image.file(image),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool isEdit = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, bottom: 5),
      child: Text(
        text,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
            color: isEdit ? Colors.black : Colors.grey),
      ),
    );
  }

  void _selectPlace(double lat, double lng, String generatedPreviewImageUrl) {
    setState(() {
      _coordinates = GeoPoint(lat, lng);
      _previewLocationImageUrl = generatedPreviewImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.myApartmentAppBarText),
        actions: [
          _buildAppBarIconButton(context),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(1.0),
              child: editedApartment == null
                  ? Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(Constants.youHaveNotAddedApartmentText),
                          ],
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AddApartmentContainerScreen.routeName);
                        },
                        tooltip: Constants.addApartmentButtonText,
                        child: const Icon(Icons.add),
                      ),
                    )
                  : Form(
                      key: _form,
                      child: ListView(
                        children: [
                          if (widget.oldApartment!.isDisabled == true)
                            Container(
                              padding: const EdgeInsets.all(10),
                              color: Colors
                                  .amber, // Set the background color for the warning message
                              child: Center(
                                child: Column(
                                  children: const [
                                    Text(
                                      Constants.privateApartmentText,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // Set the text color for the warning message
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      Constants.makeApartmentPublicText,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 35, 25,
                                            10), // Set the text color for the warning message
                                        fontStyle: FontStyle.italic,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          //images picker
                          _isInEditMode
                              ? EditMultipleImagesGrid(
                                  apartmentImagesFiles:
                                      editedApartment!['imageUrl'],
                                  oldImages: editedApartment!['imageUrl'],
                                  openImage: _openImage,
                                  removeImage: _removeImage,
                                  pickedImages: _pickedImages)
                              : PageViewGallery(
                                  imageUrls: widget.oldApartment!.imageUrl),

                          _verticalSpacer(height: 10),
                          _label(Constants.titleLabel, isEdit: _isInEditMode),
                          CustomEditField(
                            controller: _titleController,
                            isInEditMode: _isInEditMode,
                            hintText: Constants.titleLabel,
                            prefixIcon: const Icon(Icons.home_filled),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Constants.pleaseProvideTitleText;
                              }
                              return null;
                            },
                          ),

                          _verticalSpacer(),
                          _label(Constants.priceLabel, isEdit: _isInEditMode),
                          CustomEditField(
                            controller: _priceController,
                            isInEditMode: _isInEditMode,
                            keyboardType: TextInputType.number,
                            hintText: Constants.priceLabel,
                            prefixIcon: const Icon(Icons.euro),
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

                          _verticalSpacer(),
                          _label(Constants.locationLabel,
                              isEdit: _isInEditMode),

                          _isInEditMode
                              ? LocationPicker(
                                  _previewLocationImageUrl, _selectPlace)
                              : CustomEditField(
                                  controller: _locationController,
                                  isInEditMode: _isInEditMode,
                                  keyboardType: TextInputType.multiline,
                                  hintText: Constants.locationLabel,
                                  prefixIcon: const Icon(Icons.location_on),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return Constants
                                          .pleaseProvideLocationText;
                                    }
                                    return null;
                                  },
                                ),

                          _verticalSpacer(),
                          _label(Constants.descriptionLabel,
                              isEdit: _isInEditMode),
                          CustomEditField(
                            controller: _descriptionController,
                            isInEditMode: _isInEditMode,
                            hintText: Constants.descriptionLabel,
                            prefixIcon: const Icon(Icons.description),
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Constants.pleaseProvideDescriptionText;
                              }
                              return null;
                            },
                          ),

                          _verticalSpacer(),
                          _label(Constants.totalCapacityLabel,
                              isEdit: _isInEditMode),
                          CustomEditField(
                            controller: _totalCapacityController,
                            isInEditMode: _isInEditMode,
                            hintText: Constants.totalCapacityLabel,
                            prefixIcon: const Icon(Icons.people),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Constants.pleaseProvideValueText;
                              } else if (int.tryParse(value) == null ||
                                  int.parse(value).isNegative) {
                                return Constants.pleaseProvideValidNumberText;
                              }
                              return null;
                            },
                          ),

                          _verticalSpacer(),
                          _label(Constants.currentlyOcupiedLabel,
                              isEdit: _isInEditMode),
                          CustomEditField(
                            controller: _currentlyOccupiedByController,
                            isInEditMode: _isInEditMode,
                            hintText: Constants.currentlyOcupiedLabel,
                            prefixIcon: const Icon(Icons.people_alt_outlined),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Constants.pleaseProvideValueText;
                              } else if (int.tryParse(value) == null ||
                                  int.parse(value).isNegative) {
                                return Constants.pleaseProvideValidNumberText;
                              }
                              return null;
                            },
                          ),

                          _verticalSpacer(),

                          //display facilities
                          if (!_isInEditMode)
                            FacilitiesPicker(
                                initialFacilities: widget
                                    .oldApartment!.facilities
                                    .map((e) => FacilityChip(toFacilityType(e)))
                                    .toList(),
                                editMode: _isInEditMode,
                                onSave: (_) {}),

                          //edit facilities
                          if (_isInEditMode)
                            FacilitiesPicker(
                              initialFacilities: _facilities!
                                  .map((e) =>
                                      FacilityChip(toFacilityType(e as String)))
                                  .toList(),
                              editMode: _isInEditMode,
                              onSave: (facilities) {
                                setState(() {
                                  _facilities = facilities
                                      .map((chip) => chip.label)
                                      .toList();
                                });
                              },
                            ),

                          _verticalSpacer(),
                          if (!_isInEditMode)
                            RequestChart(
                                auth.FirebaseAuth.instance.currentUser!.uid),

                          _verticalSpacer(height: 25),

                          if (_isInEditMode)
                            CustomButton(
                                onTap: () {
                                  _editApartment(_savedContext!);
                                },
                                text: Constants.saveChangesButtonText),

                          // else if (apartment.isDisabled == false &&
                          //     apartment.isReserved)
                          //   GestureDetector(
                          //     onTap: () {},
                          //     child: Container(
                          //       padding: EdgeInsets.all(
                          //           MediaQuery.of(context).size.height * 0.025),
                          //       margin: EdgeInsets.symmetric(
                          //           horizontal:
                          //               MediaQuery.of(context).size.width * 0.1,
                          //           vertical:
                          //               MediaQuery.of(context).size.height *
                          //                   0.01),
                          //       decoration: BoxDecoration(
                          //         color: Colors.amber,
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //       child: Center(
                          //         child: Text(
                          //             Constants.confirmApartmentButtonText,
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .bodyText2!),
                          //       ),
                          //     ),
                          //   ),

                          _verticalSpacer(height: 20),
                        ],
                      ),
                    ),
            ),
    );
  }
}
