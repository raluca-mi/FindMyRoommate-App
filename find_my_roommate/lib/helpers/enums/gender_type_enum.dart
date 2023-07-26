enum GenderType { none, male, female, other }

GenderType toGenderType(String gender) {
  switch (gender) {
    case 'male':
      return GenderType.male;
    case 'female':
      return GenderType.female;
    case 'other':
      return GenderType.other;
    default:
      return GenderType.none;
  }
}
