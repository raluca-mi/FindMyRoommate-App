import 'package:flutter/material.dart';

import '../helpers/enums/facility_enum.dart';

class FacilityChip {
  final FacilityEnum facility;
  FacilityChip(this.facility);

  String get label {
    return facility.toString().split('.').last;
  }

  IconData get icon {
    switch (facility) {
      case FacilityEnum.tv:
        return Icons.tv;
      case FacilityEnum.wifi:
        return Icons.wifi;
      case FacilityEnum.refrigerator:
        return Icons.kitchen;
      case FacilityEnum.airConditioning:
        return Icons.ac_unit_rounded;
      case FacilityEnum.washingMachine:
        return Icons.local_laundry_service;
      case FacilityEnum.parking:
        return Icons.local_parking;
      case FacilityEnum.security:
        return Icons.key;
      case FacilityEnum.elevator:
        return Icons.elevator;
      case FacilityEnum.balcony:
        return Icons.balcony;
      case FacilityEnum.privateBathroom:
        return Icons.bathroom;
      case FacilityEnum.privateKitchen:
        return Icons.soup_kitchen;
      case FacilityEnum.disabledAccess:
        return Icons.accessible;

      default:
        return Icons.help_outline;
    }
  }

  static List<FacilityChip> availableFacilities = [
    FacilityChip(FacilityEnum.tv),
    FacilityChip(FacilityEnum.wifi),
    FacilityChip(FacilityEnum.refrigerator),
    FacilityChip(FacilityEnum.airConditioning),
    FacilityChip(FacilityEnum.washingMachine),
    FacilityChip(FacilityEnum.parking),
    FacilityChip(FacilityEnum.security),
    FacilityChip(FacilityEnum.elevator),
    FacilityChip(FacilityEnum.balcony),
    FacilityChip(FacilityEnum.privateBathroom),
    FacilityChip(FacilityEnum.privateKitchen),
    FacilityChip(FacilityEnum.disabledAccess),
  ];
  static void updateAvailableFacilities(List<FacilityChip> updatedFacilities) {
    availableFacilities = updatedFacilities;
  }
}
