import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/enums/gender_type_enum.dart';

class User with ChangeNotifier {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String imageUrl;
  final Timestamp dateOfBirth;
  final GenderType gender;
  final String description;
  final String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.imageUrl,
    required this.dateOfBirth,
    required this.gender,
    required this.description,
    required this.phoneNumber,
  });
}
