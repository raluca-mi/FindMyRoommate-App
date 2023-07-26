import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Request with ChangeNotifier {
  final String id;
  final String applicantId;
  final String ownerId;
  final String apartmentId;
  final Timestamp sentDate;
  bool? approved;

  Request({
    required this.id,
    required this.applicantId,
    required this.ownerId,
    required this.apartmentId,
    required this.sentDate,
    required this.approved,
  });
}
