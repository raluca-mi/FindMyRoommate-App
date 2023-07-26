import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Apartment with ChangeNotifier {
  String id;
  String ownerId;
  List<dynamic> roommatesIds;
  String title;
  int price;
  String previewLocationImageUrl;
  String address;
  GeoPoint coordinates;
  List<dynamic> facilities;
  String description;
  List<dynamic> imageUrl;
  Timestamp createdAt;
  Timestamp lastModifiedAt;
  int totalCapacity;
  int currentlyOccupiedBy;
  bool isReserved;
  bool isDisabled;

  Apartment(
      {required this.id,
      required this.ownerId,
      required this.roommatesIds,
      required this.title,
      required this.price,
      required this.previewLocationImageUrl,
      required this.address,
      required this.coordinates,
      required this.facilities,
      required this.description,
      required this.imageUrl,
      required this.createdAt,
      required this.lastModifiedAt,
      required this.totalCapacity,
      required this.currentlyOccupiedBy,
      this.isReserved = false,
      this.isDisabled = false});
}
