import 'package:find_my_roommate/helpers/enums/sort_option_enum.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../helpers/enums/facility_enum.dart';
import '../helpers/location_helper.dart';
import '../models/apartment.dart';
import '../helpers/db_helper.dart';

class ApartmentsProvider with ChangeNotifier {
  List<Apartment> _apartments = [];
  List<Apartment> _filteredApartments = [];

  List<Apartment> get apartments {
    return [..._apartments];
  }

  List<Apartment> get filteredApartments {
    return [..._filteredApartments];
  }

  //filter apartments by search query
  Future<void> searchApartments(
      String? searchedLocality,
      List<FacilityEnum> selectedFacilities,
      int selectedPrice,
      int selectedCapacity,
      SortOption? selectedSortOption) async {
    await fetchOthersApartments();
    _filteredApartments = _apartments;

    //apply search
    if (searchedLocality != null) {
      //search apartments by locality
      _filteredApartments =
          await _searchApartmentsByLocation(_apartments, searchedLocality);
    } else {
      _filteredApartments = _apartments;
    }

    // filter apartments
    if (selectedFacilities.isNotEmpty ||
        selectedPrice != 0 ||
        selectedCapacity != 0) {
      _filteredApartments = _filterApartments(_filteredApartments,
          selectedFacilities, selectedPrice, selectedCapacity);
    }

    if (selectedSortOption != null) {
      // sort apartments based on selected sort option
      if (selectedSortOption == SortOption.priceAscending) {
        _filteredApartments.sort((a, b) => a.price.compareTo(b.price));
      } else if (selectedSortOption == SortOption.priceDescending) {
        _filteredApartments.sort((a, b) => b.price.compareTo(a.price));
      } else if (selectedSortOption == SortOption.fromNewestToOldest) {
        _filteredApartments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (selectedSortOption == SortOption.fromOldestToNewest) {
        _filteredApartments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    }

    notifyListeners();
  }

  //search apartments by location
  Future<List<Apartment>> _searchApartmentsByLocation(
      List<Apartment> apartments, String searchedLocality) async {
    // Reverse geocode the coordinates to obtain the locality

    // Filter apartments by the searched locality
    List<Apartment> filteredByLocality = apartments
        .where((apartment) => apartment.address.contains(searchedLocality))
        .toList();

    return filteredByLocality;
  }

  //get all apartments that contain in the facilities list the selected facilities
  List<Apartment> _filterApartments(
    List<Apartment> searchedResults,
    List<FacilityEnum> selectedFacilities,
    int selectedMaxPrice,
    int selectedCapacity,
  ) {
    if (selectedFacilities.isEmpty &&
        selectedMaxPrice == 0 &&
        selectedCapacity == 0) {
      return searchedResults;
    }

    //convert list of enums to list of dynamic
    List<dynamic> selectedFacilitiesDynamic = selectedFacilities
        .map((selectedFacility) => selectedFacility.name)
        .toList();
    //filter apartments based on selected facilities
    _filteredApartments = searchedResults.where((apartment) {
      return selectedFacilitiesDynamic.every((selectedFacility) {
        return apartment.facilities.contains(selectedFacility);
      });
    }).toList();

    if (selectedMaxPrice != 0) {
      _filteredApartments = _filteredApartments.where((apartment) {
        return apartment.price <= selectedMaxPrice;
      }).toList();
    }

    if (selectedCapacity != 0) {
      _filteredApartments = _filteredApartments.where((apartment) {
        return apartment.totalCapacity == selectedCapacity;
      }).toList();
    }
    return _filteredApartments;
  }

  //get all apartments from database without the current user's apartments
  Future<void> fetchOthersApartments() async {
    final apartmentsData = await DBHelper.fetchOthersApartments(
        auth.FirebaseAuth.instance.currentUser!.uid);

    _apartments = apartmentsData.map(
      (apartment) {
        return Apartment(
          id: apartment['id'],
          ownerId: apartment['ownerId'],
          roommatesIds: apartment['roommatesIds'],
          title: apartment['title'],
          previewLocationImageUrl: apartment['previewLocationImageUrl'],
          address: apartment['address'],
          coordinates: apartment['coordinates'],
          price: apartment['price'],
          imageUrl: apartment['imageUrl'],
          description: apartment['description'],
          facilities: apartment['facilities'],
          createdAt: apartment['createdAt'],
          lastModifiedAt: apartment['lastModifiedAt'],
          currentlyOccupiedBy: apartment['currentlyOccupiedBy'],
          totalCapacity: apartment['totalCapacity'],
          isReserved: apartment['isReserved'],
          isDisabled: apartment['isDisabled'],
        );
      },
    ).toList();

    notifyListeners();
  }

  //get apartment by id
  Future<Apartment> findById(String apartmentId) async {
    final apartmentData = await DBHelper.findApartmentById(apartmentId);

    final apartment = Apartment(
      id: apartmentData['id'],
      ownerId: apartmentData['ownerId'],
      roommatesIds: apartmentData['roommatesIds'],
      title: apartmentData['title'],
      previewLocationImageUrl: apartmentData['previewLocationImageUrl'],
      address: apartmentData['address'],
      coordinates: apartmentData['coordinates'],
      price: apartmentData['price'],
      imageUrl: apartmentData['imageUrl'],
      description: apartmentData['description'],
      facilities: apartmentData['facilities'],
      createdAt: apartmentData['createdAt'],
      lastModifiedAt: apartmentData['lastModifiedAt'],
      currentlyOccupiedBy: apartmentData['currentlyOccupiedBy'],
      totalCapacity: apartmentData['totalCapacity'],
      isReserved: apartmentData['isReserved'],
      isDisabled: apartmentData['isDisabled'],
    );

    return apartment;
  }

  //get apartment by owner id
  Future<Apartment?> findByOwnerId(String ownerId) async {
    final apartmentData = await DBHelper.findApartmentsByOwnerId(ownerId);

    final apartments = apartmentData.map(
      (apartment) {
        return Apartment(
          id: apartment['id'],
          ownerId: apartment['ownerId'],
          roommatesIds: apartment['roommatesIds'],
          title: apartment['title'],
          previewLocationImageUrl: apartment['previewLocationImageUrl'],
          address: apartment['address'],
          coordinates: apartment['coordinates'],
          price: apartment['price'],
          imageUrl: apartment['imageUrl'],
          description: apartment['description'],
          facilities: apartment['facilities'],
          createdAt: apartment['createdAt'],
          lastModifiedAt: apartment['lastModifiedAt'],
          currentlyOccupiedBy: apartment['currentlyOccupiedBy'],
          totalCapacity: apartment['totalCapacity'],
          isReserved: apartment['isReserved'],
          isDisabled: apartment['isDisabled'],
        );
      },
    ).toList();

    if (apartments.isEmpty) {
      return null;
    }

    return apartments.first;
  }

  //add apartment
  Future<void> addApartment(Apartment apartment) async {
    await DBHelper.addApartment(apartment);

    notifyListeners();
  }

  //update apartment
  Future<void> updateApartment(
      String apartmentId, Apartment updatedApartment) async {
    final apartmentMap = {
      'id': updatedApartment.id,
      'ownerId': updatedApartment.ownerId,
      'roommatesIds': updatedApartment.roommatesIds,
      'title': updatedApartment.title,
      'previewLocationImageUrl': updatedApartment.previewLocationImageUrl,
      'address': updatedApartment.address,
      'coordinates': updatedApartment.coordinates,
      'price': updatedApartment.price,
      'imageUrl': updatedApartment.imageUrl,
      'description': updatedApartment.description,
      'facilities': updatedApartment.facilities,
      'createdAt': updatedApartment.createdAt,
      'lastModifiedAt': DateTime.now(),
      'currentlyOccupiedBy': updatedApartment.currentlyOccupiedBy,
      'totalCapacity': updatedApartment.totalCapacity,
      'isReserved': updatedApartment.isReserved,
      'isDisabled': updatedApartment.isDisabled,
    };
    await DBHelper.updateApartmentById(apartmentId, apartmentMap);
    final apartmentIndex =
        _apartments.indexWhere((apartment) => apartment.id == apartmentId);

    if (apartmentIndex >= 0) {
      notifyListeners();
    }
  }

  //delete apartment
  Future<void> deleteApartment(String apartmentId) async {
    await DBHelper.deleteApartmentById(apartmentId);
    _apartments.removeWhere((apartment) => apartment.id == apartmentId);
    notifyListeners();
  }

  Future<void> updateIsDisabledField(
      String apartmentId, bool isDisabledStatus) async {
    try {
      await DBHelper.updateDisabledField(apartmentId, isDisabledStatus);
    } catch (error) {
      throw ('${Constants.errorOccuredText}: ${error.toString()}');
    }
  }

  Future<void> addRoommateIdToApartment(String apartmentId, String userId) {
    try {
      return DBHelper.addRoommateIdToApartment(apartmentId, userId);
    } catch (error) {
      throw ('${Constants.errorOccuredText}: ${error.toString()}');
    }
  }

  Future<void> removeRoommateIdFromApartment(
      String apartmentId, String userId) {
    try {
      return DBHelper.removeRoommateIdFromApartment(apartmentId, userId);
    } catch (error) {
      throw ('${Constants.errorOccuredText}: ${error.toString()}');
    }
  }

  //increment currently occupied by field by apartment id
  Future<void> incrementCurrentlyOccupiedByField(String apartmentId) async {
    await DBHelper.incrementCurrentlyOccupiedBy(apartmentId);

    notifyListeners();
  }

  //decrement currently occupied by field by apartment id
  Future<void> decrementCurrentlyOccupiedByField(String apartmentId) async {
    await DBHelper.decrementCurrentlyOccupiedBy(apartmentId);

    notifyListeners();
  }

  //calculate average prices of apartments grouped by cities
  Future<Map<String, Map<String, dynamic>>>
      calculateAveragePricesByCities() async {
    final allApartmentsMap = await DBHelper.fetchApartments();
    final allApartments = allApartmentsMap.map(
      (apartment) {
        return Apartment(
          id: apartment['id'],
          ownerId: apartment['ownerId'],
          roommatesIds: apartment['roommatesIds'],
          title: apartment['title'],
          previewLocationImageUrl: apartment['previewLocationImageUrl'],
          address: apartment['address'],
          coordinates: apartment['coordinates'],
          price: apartment['price'],
          imageUrl: apartment['imageUrl'],
          description: apartment['description'],
          facilities: apartment['facilities'],
          createdAt: apartment['createdAt'],
          lastModifiedAt: apartment['lastModifiedAt'],
          currentlyOccupiedBy: apartment['currentlyOccupiedBy'],
          totalCapacity: apartment['totalCapacity'],
          isReserved: apartment['isReserved'],
          isDisabled: apartment['isDisabled'],
        );
      },
    ).toList();

    Map<String, Map<String, dynamic>> localityData = {};
    for (final apartment in allApartments) {
      final latitude = apartment.coordinates.latitude;
      final longitude = apartment.coordinates.longitude;
      final address =
          await LocationHelper.getAddressComponents(latitude, longitude);
      final locality = address['locality'];

      if (!localityData.containsKey(locality)) {
        localityData[locality!] = {
          'totalPrice': apartment.price,
          'count': 1,
        };
      } else {
        localityData[locality]!['totalPrice'] += apartment.price;
        localityData[locality]!['count']++;
      }
    }

    //calculate average price for each locality
    for (final locality in localityData.keys) {
      final totalPrice = localityData[locality]!['totalPrice'];
      final count = localityData[locality]!['count'];
      var averagePrice = totalPrice / count;

      averagePrice = double.parse(averagePrice.toStringAsFixed(2));

      localityData[locality]!['averagePrice'] = averagePrice;
    }

    return localityData;
  }

  //count apartments by cities
  Future<Map<String, int>> countApartmentsByCities() async {
    final allApartmentsMap = await DBHelper.fetchApartments();
    final allApartments = allApartmentsMap.map(
      (apartment) {
        return Apartment(
          id: apartment['id'],
          ownerId: apartment['ownerId'],
          roommatesIds: apartment['roommatesIds'],
          title: apartment['title'],
          previewLocationImageUrl: apartment['previewLocationImageUrl'],
          address: apartment['address'],
          coordinates: apartment['coordinates'],
          price: apartment['price'],
          imageUrl: apartment['imageUrl'],
          description: apartment['description'],
          facilities: apartment['facilities'],
          createdAt: apartment['createdAt'],
          lastModifiedAt: apartment['lastModifiedAt'],
          currentlyOccupiedBy: apartment['currentlyOccupiedBy'],
          totalCapacity: apartment['totalCapacity'],
          isReserved: apartment['isReserved'],
          isDisabled: apartment['isDisabled'],
        );
      },
    ).toList();

    Map<String, int> localityData = {};
    for (final apartment in allApartments) {
      dynamic locality;
      final latitude = apartment.coordinates.latitude;
      final longitude = apartment.coordinates.longitude;
      await LocationHelper.getAddressComponents(latitude, longitude)
          .then((value) {
        locality = value['locality'];
        if (!localityData.containsKey(locality)) {
          localityData[locality!] = 1;
        } else {
          localityData[locality] = localityData[locality]! + 1;
        }
      });
    }

    return localityData;
  }
}
