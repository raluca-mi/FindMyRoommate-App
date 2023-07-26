import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_my_roommate/widgets/customized/gender_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';

import '../../helpers/constants.dart';
import '../../helpers/convertor.dart';
import '../../helpers/display_helper.dart';
import '../../helpers/enums/gender_type_enum.dart';
import '../../models/user.dart';
import '../../providers/users_provider.dart';
import '../../widgets/pickers/user_image_picker.dart';
import '../../widgets/customized/custom_button.dart';

class EditUserScreen extends StatefulWidget {
  static const routeName = Constants.editUserScreenRoute;
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _form = GlobalKey<FormState>();
  bool _isInEditMode = false;

  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  var _userImageFile;
  GenderType? _pickedGender;
  DateTime? _birthDate;
  bool _isLoading = false;
  // ignore: prefer_typing_uninitialized_variables
  var _savedContext;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _savedContext = context;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isInEditMode = !_isInEditMode;
    });
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _selectedGender(GenderType gender) {
    _pickedGender = gender;
  }

  void _pickDateOfBirth() {
    showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        _birthDate = value;
        _dateOfBirthController.text = formatDate(value);
      }
    });
  }

  Future<void> _saveForm(BuildContext savedContext, User oldUser) async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    if (_birthDate == null || int.parse(calculateAge(_birthDate!)) < 18) {
      DisplayHelper.showErrorMessage(
          savedContext, Constants.pleaseProvideValidAgeText);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (oldUser.id != '') {
      if (_userImageFile != null && _userImageFile is File) {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child(Constants.userImagesBucket)
              .child('${oldUser.id}.jpg');

          await ref.putFile(_userImageFile as File);

          final url = await ref.getDownloadURL();

          final editedUser = User(
              id: oldUser.id,
              email: _emailController.text.trim(),
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              password: oldUser.password,
              imageUrl: url,
              dateOfBirth: _birthDate == null
                  ? oldUser.dateOfBirth
                  : Timestamp.fromDate(_birthDate!),
              gender: _pickedGender ?? oldUser.gender,
              description: _descriptionController.text,
              phoneNumber: _phoneNumberController.text.trim());

          // ignore: use_build_context_synchronously
          await Provider.of<UsersProvider>(context, listen: false)
              .updateUser(editedUser.id, editedUser);
          // ignore: use_build_context_synchronously
          DisplayHelper.showSuccessMessage(
              context, Constants.profileEditedSuccessfullyText);
        } on FirebaseException catch (e) {
          DisplayHelper.showErrorMessage(savedContext,
              '${Constants.errorUploadingImageText}: ${e.message}');
          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          DisplayHelper.showErrorMessage(
              savedContext, Constants.errorUploadingImageText);
        } finally {
          setState(() {
            _isLoading = false;
            _isInEditMode = false;
          });
        }
      } else {
        final editedUser = User(
            id: oldUser.id,
            email: _emailController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            password: oldUser.password,
            imageUrl: oldUser.imageUrl,
            dateOfBirth: _birthDate == null
                ? oldUser.dateOfBirth
                : Timestamp.fromDate(_birthDate!),
            gender: _pickedGender ?? oldUser.gender,
            description: _descriptionController.text,
            phoneNumber: _phoneNumberController.text.trim());

        // ignore: use_build_context_synchronously
        await Provider.of<UsersProvider>(context, listen: false)
            .updateUser(oldUser.id, editedUser);
        setState(() {
          _isLoading = false;
          _isInEditMode = false;
        });
        // ignore: use_build_context_synchronously
        DisplayHelper.showSuccessMessage(
            context, Constants.profileEditedSuccessfullyText);
      }
    }
  }

  Widget _label(String text, {bool isEdit = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 5),
      child: Text(
        text,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
            color: isEdit ? Colors.black : Colors.grey),
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
        title: const Text(Constants.editUserAppBarText),
        actions: [
          IconButton(
            icon: _isInEditMode
                ? const Icon(Icons.edit_off)
                : const Icon(Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(1.0),
              child: FutureBuilder(
                  future: Provider.of<UsersProvider>(context, listen: false)
                      .findById(auth.FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      final user = snapshot.data as User;

                      _emailController.text = user.email;
                      _firstNameController.text = user.firstName;
                      _lastNameController.text = user.lastName;
                      _phoneNumberController.text = user.phoneNumber;
                      _descriptionController.text = user.description;
                      _dateOfBirthController.text =
                          formatDate(user.dateOfBirth.toDate());
                      _birthDate = user.dateOfBirth.toDate();
                      _userImageFile = NetworkImage(user.imageUrl);

                      return Form(
                        key: _form,
                        child: ListView(
                          children: [
                            _verticalSpacer(height: 20),

                            UserImagePicker(
                              _pickedImage,
                              selectedImage: _userImageFile,
                              editMode: _isInEditMode,
                            ),
                            _verticalSpacer(height: 10),

                            //Email text field readonly
                            _label(Constants.emailLabel, isEdit: false),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                //never editable
                                enabled: false,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  hintText: Constants.emailLabel,
                                ),
                              ),
                            ),

                            _verticalSpacer(),
                            _label(Constants.firstNameLabel,
                                isEdit: _isInEditMode),
                            //First Name text field
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                enabled: _isInEditMode,
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  hintText: Constants.firstNameLabel,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Constants.pleaseProvideFirstNameText;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            _verticalSpacer(),
                            //Last Name text field
                            _label(Constants.lastNameLabel,
                                isEdit: _isInEditMode),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                enabled: _isInEditMode,
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon:
                                      const Icon(Icons.person_outline_rounded),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  hintText: Constants.lastNameLabel,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Constants.pleaseProvideLastNameText;
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _verticalSpacer(),

                            //date of birth
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      enabled: _isInEditMode,
                                      readOnly: true,
                                      controller: _dateOfBirthController,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: _pickDateOfBirth,
                                          icon:
                                              const Icon(Icons.calendar_today),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .backgroundColor),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        fillColor: Colors.grey[200],
                                        filled: true,
                                        hintText: Constants.birthDateLabel,
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return Constants
                                              .pleaseProvideDateOfBirthText;
                                        } else if (_birthDate == null) {
                                          return Constants
                                              .pleaseProvideDateOfBirthText;
                                        } else if (int.parse(
                                                calculateAge(_birthDate!)) <
                                            18) {
                                          return Constants.invalidAgeText;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _verticalSpacer(),

                            _label(Constants.genderLabel,
                                isEdit: _isInEditMode),
                            _isInEditMode
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: GenderDropdown(_selectedGender,
                                        initialValue:
                                            _pickedGender ?? user.gender),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: TextFormField(
                                      //never editable
                                      enabled: false,
                                      initialValue: user.gender.name,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .backgroundColor),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        fillColor: Colors.grey[200],
                                        filled: true,
                                        hintText: Constants.emailLabel,
                                      ),
                                    ),
                                  ),

                            _verticalSpacer(),

                            _label(Constants.descriptionLabel,
                                isEdit: _isInEditMode),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                enabled: _isInEditMode,
                                controller: _descriptionController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  hintText: Constants.descriptionLabel,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Constants.pleaseProvideLastNameText;
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _verticalSpacer(),

                            _label(Constants.phoneNumberLabel,
                                isEdit: _isInEditMode),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                enabled: _isInEditMode,
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  hintText: Constants.phoneNumberLabel,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Constants
                                        .pleaseProvidePhoneNumberText;
                                  } else if (!RegExp(Constants.phoneNumberRegex)
                                      .hasMatch(value)) {
                                    return Constants.invalidPhoneNumberText;
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _verticalSpacer(),

                            _verticalSpacer(height: 25),
                            if (_isInEditMode)
                              CustomButton(
                                  onTap: () => _saveForm(_savedContext, user),
                                  text: Constants.saveChangesButtonText),
                            _verticalSpacer(height: 20),
                          ],
                        ),
                      );
                    }
                  }),
            ),
    );
  }
}
