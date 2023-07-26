import '../../models/apartment.dart';

enum ApartmentStatus {
  available,
  reserved,
  disabled,
}

ApartmentStatus getApartmentStatus(Apartment apartment) {
  if (apartment.isDisabled) {
    return ApartmentStatus.disabled;
  } else if (apartment.isReserved) {
    return ApartmentStatus.reserved;
  } else {
    return ApartmentStatus.available;
  }
}
