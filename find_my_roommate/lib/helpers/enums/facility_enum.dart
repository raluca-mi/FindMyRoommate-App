enum FacilityEnum {
  tv,
  wifi,
  refrigerator,
  airConditioning,
  washingMachine,
  parking,
  security,
  elevator,
  balcony,
  privateBathroom,
  privateKitchen,
  disabledAccess,
}

FacilityEnum toFacilityType(String facility) {
  switch (facility) {
    case 'tv':
      return FacilityEnum.tv;
    case 'wifi':
      return FacilityEnum.wifi;
    case 'refrigerator':
      return FacilityEnum.refrigerator;
    case 'airConditioning':
      return FacilityEnum.airConditioning;
    case 'washingMachine':
      return FacilityEnum.washingMachine;
    case 'parking':
      return FacilityEnum.parking;
    case 'security':
      return FacilityEnum.security;
    case 'elevator':
      return FacilityEnum.elevator;
    case 'balcony':
      return FacilityEnum.balcony;
    case 'privateBathroom':
      return FacilityEnum.privateBathroom;
    case 'privateKitchen':
      return FacilityEnum.privateKitchen;
    case 'disabledAccess':
      return FacilityEnum.disabledAccess;
    default:
      return FacilityEnum.tv;
  }
}
