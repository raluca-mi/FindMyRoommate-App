import 'dart:io';
import 'package:find_my_roommate/widgets/customized/gender_dropdown.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../helpers/convertor.dart';
import '../../helpers/display_helper.dart';
import '../../helpers/constants.dart';
import '../../helpers/enums/gender_type_enum.dart';
import '../../widgets/customized/custom_button.dart';
import '../../widgets/customized/custom_field.dart';
import '../../widgets/pickers/user_image_picker.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;

  const RegisterScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  var _userImageFile;
  GenderType? _gender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();

    super.dispose();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorMessage(
      String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessMessage(
      String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _selectedGender(GenderType gender) {
    _gender = gender;
  }

  void _pickDateOfBirth() {
    showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _birthDate = value;
          _dateOfBirthController.text = formatDate(value);
        });
      }
    });
  }

  bool isPasswordConfirmed() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _tryRegister() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _gender == null ||
        _descriptionController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      throw FirebaseAuthException(code: 'requred-fields');
    }
    if (_birthDate == null || int.parse(calculateAge(_birthDate!)) < 18) {
      throw FirebaseAuthException(code: 'age-not-valid');
    }

    if (!RegExp(Constants.phoneNumberRegex)
        .hasMatch(_phoneNumberController.text.trim())) {
      throw FirebaseAuthException(code: 'phone-number-not-valid');
    }
    UserCredential authResult;
    //create user in firebase auth
    authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);

    final ref = FirebaseStorage.instance
        .ref()
        .child(Constants.userImagesBucket)
        .child('${authResult.user!.uid}.jpg');

    await ref.putFile(_userImageFile!);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Constants.usersCollection)
        .doc(authResult.user!.uid)
        .set({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'imageUrl': url,
      'dateOfBirth': Timestamp.fromDate(_birthDate!),
      'gender': _gender!.name,
      'description': _descriptionController.text,
      'phoneNumber': _phoneNumberController.text,
    });
  }

  void _register() async {
    NavigatorState navigator = Navigator.of(context);
    DisplayHelper.showLoadingSpinner(context);
    if (_userImageFile == null) {
      showErrorMessage(Constants.noImageSelectedText);
    } else if (!isPasswordConfirmed()) {
      showErrorMessage(Constants.passwordDoNotMatchText);
    } else {
      try {
        await _tryRegister();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requred-fields') {
          showErrorMessage(Constants.fieldsRequiredText);
        } else if (e.code == 'age-not-valid') {
          showErrorMessage(Constants.invalidAgeText);
        } else if (e.code == 'network-request-failed') {
          showErrorMessage(Constants.noInternetConnectionText);
        } else if (e.code == 'unknown') {
          showErrorMessage(Constants.fieldsRequiredText);
        } else if (e.code == 'email-already-in-use') {
          showErrorMessage(Constants.emailAlreadyInUseText);
        } else if (e.code == 'weak-password') {
          showErrorMessage(Constants.weakPasswordText);
        } else if (e.code == 'invalid-email') {
          showErrorMessage(Constants.invalidEmailText);
        } else if (e.code == 'passwords-dont-match') {
          showErrorMessage(Constants.passwordDoNotMatchText);
        } else if (e.code == 'phone-number-not-valid') {
          showErrorMessage(Constants.invalidPhoneNumberText);
        } else {
          showErrorMessage('${Constants.errorOccuredText}: ${e.message!}');
        }
      } catch (e) {
        showErrorMessage('${Constants.errorOccuredText}: ${e.toString()}');
      }
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: mediaQuery.size.height * 0.02,
                  ),

                  //avatar
                  UserImagePicker(_pickedImage),

                  SizedBox(
                    height: mediaQuery.size.height * 0.003,
                  ),

                  //welcome back
                  Text(
                    Constants.registerText,
                    style: Theme.of(context).textTheme.bodyText2!,
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.05,
                  ),

                  //first name
                  CustomTextField(
                    controller: _firstNameController,
                    hintText: Constants.firstNameLabel,
                    obscureText: Constants.falseText,
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //last name
                  CustomTextField(
                      controller: _lastNameController,
                      hintText: Constants.lastNameLabel,
                      obscureText: Constants.falseText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //date of birth
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.size.width * 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateOfBirthController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _pickDateOfBirth,
                                icon: const Icon(Icons.calendar_today),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).backgroundColor),
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
                              hintText: Constants.birthDateLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //gender

                  SizedBox(
                    width: mediaQuery.size.width * 0.8,
                    child: GenderDropdown(_selectedGender),
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //description
                  CustomTextField(
                      controller: _descriptionController,
                      hintText: Constants.descriptionLabel,
                      obscureText: Constants.falseText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //phone
                  CustomTextField(
                      controller: _phoneNumberController,
                      hintText: Constants.phoneNumberLabel,
                      obscureText: Constants.falseText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //email
                  CustomTextField(
                      controller: _emailController,
                      hintText: Constants.emailLabel,
                      obscureText: Constants.falseText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //password
                  CustomTextField(
                      controller: _passwordController,
                      hintText: Constants.passwordHintText,
                      obscureText: Constants.trueText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.018,
                  ),

                  //password
                  CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: Constants.confirmPasswordHintText,
                      obscureText: Constants.trueText),

                  SizedBox(
                    height: mediaQuery.size.height * 0.04,
                  ),

                  //register button

                  CustomButton(
                    onTap: _register,
                    text: Constants.registerButtonText,
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.05,
                  ),

                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Constants.alreadyHaveAccountText,
                          style: Theme.of(context).textTheme.headline2!),
                      SizedBox(
                        width: mediaQuery.size.width * 0.01,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(Constants.loginNowText,
                            style: Theme.of(context).textTheme.headline3!),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mediaQuery.size.height * 0.06,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
