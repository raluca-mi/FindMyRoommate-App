import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/constants.dart';
import '../models/apartment.dart';
import '../models/request.dart';

class DBHelper {
  // APARTMENTS //

  //get all apartments from the database
  static Future<List<Map<String, dynamic>>> fetchApartments() async {
    final apartments = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .get();

    if (apartments.docs.isEmpty) {
      return [];
    }

    final apartmentsList = apartments.docs.map((apartment) {
      return {
        'id': apartment.id,
        'ownerId': apartment['ownerId'],
        'roommatesIds': apartment['roommatesIds'],
        'title': apartment['title'],
        'previewLocationImageUrl': apartment['previewLocationImageUrl'],
        'address': apartment['address'],
        'coordinates': apartment['coordinates'],
        'price': apartment['price'],
        'imageUrl': apartment['imageUrl'],
        'description': apartment['description'],
        'facilities': apartment['facilities'],
        'createdAt': apartment['createdAt'],
        'lastModifiedAt': apartment['lastModifiedAt'],
        'totalCapacity': apartment['totalCapacity'],
        'currentlyOccupiedBy': apartment['currentlyOccupiedBy'],
        'isReserved': apartment['isReserved'],
        'isDisabled': apartment['isDisabled'],
      };
    }).toList();

    if (apartmentsList.isEmpty) {
      return [];
    }

    return apartmentsList;
  }

  //get all apartments except the ones owned by the current user
  static Future<List<Map<String, dynamic>>> fetchOthersApartments(
      String userId) async {
    //fetch all apartments except the ones owned by the current user and that are not disabled
    final apartments = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .where('ownerId', isNotEqualTo: userId)
        .where('isDisabled', isEqualTo: false)
        .get();

    if (apartments.docs.isEmpty) {
      return [];
    }

    final apartmentsList = apartments.docs.map((apartment) {
      return {
        'id': apartment.id,
        'ownerId': apartment['ownerId'],
        'roommatesIds': apartment['roommatesIds'],
        'title': apartment['title'],
        'previewLocationImageUrl': apartment['previewLocationImageUrl'],
        'address': apartment['address'],
        'coordinates': apartment['coordinates'],
        'price': apartment['price'],
        'imageUrl': apartment['imageUrl'],
        'description': apartment['description'],
        'facilities': apartment['facilities'],
        'createdAt': apartment['createdAt'],
        'lastModifiedAt': apartment['lastModifiedAt'],
        'totalCapacity': apartment['totalCapacity'],
        'currentlyOccupiedBy': apartment['currentlyOccupiedBy'],
        'isReserved': apartment['isReserved'],
        'isDisabled': apartment['isDisabled'],
      };
    }).toList();

    if (apartmentsList.isEmpty) {
      return [];
    }

    return apartmentsList;
  }

  //get apartment by id from the database
  static Future<Map<String, dynamic>> findApartmentById(
      String apartmentId) async {
    final apartment = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .get();

    final apartmentMap = {
      'id': apartment.id,
      'ownerId': apartment['ownerId'],
      'roommatesIds': apartment['roommatesIds'],
      'title': apartment['title'],
      'previewLocationImageUrl': apartment['previewLocationImageUrl'],
      'address': apartment['address'],
      'coordinates': apartment['coordinates'],
      'price': apartment['price'],
      'imageUrl': apartment['imageUrl'],
      'description': apartment['description'],
      'facilities': apartment['facilities'],
      'createdAt': apartment['createdAt'],
      'lastModifiedAt': apartment['lastModifiedAt'],
      'totalCapacity': apartment['totalCapacity'],
      'currentlyOccupiedBy': apartment['currentlyOccupiedBy'],
      'isReserved': apartment['isReserved'],
      'isDisabled': apartment['isDisabled'],
    };

    return apartmentMap;
  }

  //get apartments by owner id from the database
  static Future<List<Map<String, dynamic>>> findApartmentsByOwnerId(
      String ownerId) async {
    final apartments = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    if (apartments.docs.isEmpty) {
      return [];
    }

    final apartmentsList = apartments.docs.map((apartment) {
      return {
        'id': apartment.id,
        'ownerId': apartment['ownerId'],
        'roommatesIds': apartment['roommatesIds'],
        'title': apartment['title'],
        'previewLocationImageUrl': apartment['previewLocationImageUrl'],
        'address': apartment['address'],
        'coordinates': apartment['coordinates'],
        'price': apartment['price'],
        'imageUrl': apartment['imageUrl'],
        'description': apartment['description'],
        'facilities': apartment['facilities'],
        'createdAt': apartment['createdAt'],
        'lastModifiedAt': apartment['lastModifiedAt'],
        'totalCapacity': apartment['totalCapacity'],
        'currentlyOccupiedBy': apartment['currentlyOccupiedBy'],
        'isReserved': apartment['isReserved'],
        'isDisabled': apartment['isDisabled'],
      };
    }).toList();

    if (apartmentsList.isEmpty) {
      return [];
    }

    return apartmentsList;
  }

  //add apartment to the database
  static Future<void> addApartment(Apartment apartment) async {
    final apartmentMap = {
      'ownerId': apartment.ownerId,
      'roommatesIds': apartment.roommatesIds,
      'title': apartment.title,
      'previewLocationImageUrl': apartment.previewLocationImageUrl,
      'address': apartment.address,
      'coordinates': apartment.coordinates,
      'price': apartment.price,
      'imageUrl': apartment.imageUrl,
      'description': apartment.description,
      'facilities': apartment.facilities,
      'createdAt': Timestamp.now(),
      'lastModifiedAt': Timestamp.now(),
      'totalCapacity': apartment.totalCapacity,
      'currentlyOccupiedBy': apartment.currentlyOccupiedBy,
      'isReserved': apartment.isReserved,
      'isDisabled': false,
    };
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .add(apartmentMap);
  }

  //update apartment by id in the database
  static Future<void> updateApartmentById(
      String apartmentId, Map<String, dynamic> updatedApartment) async {
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .update(updatedApartment);
  }

  //delete apartment by id from the database
  static Future<void> deleteApartmentById(String apartmentId) async {
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .delete();
  }

  //increment apartment's currently occupied by value by 1
  static Future<void> incrementCurrentlyOccupiedBy(String apartmentId) async {
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .update({
      'currentlyOccupiedBy': FieldValue.increment(1),
    });

    final apartment = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .get();

    if (apartment['currentlyOccupiedBy'] == apartment['totalCapacity']) {
      await updateReservedField(apartmentId, true);
    }
  }

  //decrement apartment's currently occupied by value by 1
  static Future<void> decrementCurrentlyOccupiedBy(String apartmentId) async {
    await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .update({
      'currentlyOccupiedBy': FieldValue.increment(-1),
    });

    final apartment = await FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId)
        .get();

    if (apartment['currentlyOccupiedBy'] < apartment['totalCapacity']) {
      await updateReservedField(apartmentId, false);
    }
  }

  //update isReserved field in the database
  static Future<void> updateReservedField(
      String apartmentId, bool isReserved) async {
    final apartmentRef = FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId);

    await apartmentRef.update({'isReserved': isReserved});
  }

  //update isDisabled field in the database
  static Future<void> updateDisabledField(
      String apartmentId, bool isDisabledStatus) async {
    final apartmentRef = FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId);

    await apartmentRef.update({'isDisabled': isDisabledStatus});
  }

  //add user id to roommatesIds array in the database
  static Future<void> addRoommateIdToApartment(
      String apartmentId, String userId) async {
    final apartmentRef = FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId);

    await apartmentRef.update({
      'roommatesIds': FieldValue.arrayUnion([userId]),
    });
  }

  //remove user id from roommatesIds array in the database
  static Future<void> removeRoommateIdFromApartment(
      String apartmentId, String userId) async {
    final apartmentRef = FirebaseFirestore.instance
        .collection(Constants.apartmentsCollection)
        .doc(apartmentId);

    await apartmentRef.update({
      'roommatesIds': FieldValue.arrayRemove([userId]),
    });
  }

  // USERS //

  //get all users from the database
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final users = await FirebaseFirestore.instance
        .collection(Constants.usersCollection)
        .get();

    if (users.docs.isEmpty) {
      return [];
    }

    final usersList = users.docs.map((user) {
      return {
        'id': user.id,
        'email': user['email'],
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'password': user['password'],
        'imageUrl': user['imageUrl'],
        'dateOfBirth': user['dateOfBirth'],
        'gender': user['gender'],
        'description': user['description'],
        'phoneNumber': user['phoneNumber'],
      };
    }).toList();

    if (usersList.isEmpty) {
      return [];
    }

    return usersList;
  }

  //get user by id from the database
  static Future<Map<String, dynamic>> findUserById(String userId) async {
    //get user by id
    final user = await FirebaseFirestore.instance
        .collection(Constants.usersCollection)
        .doc(userId)
        .get();

    //convert user to a map
    final userMap = {
      'id': user.id,
      'email': user['email'] ?? '',
      'firstName': user['firstName'] ?? '',
      'lastName': user['lastName'] ?? '',
      'password': user['password'] ?? '',
      'imageUrl': user['imageUrl'] ?? '',
      'dateOfBirth': user['dateOfBirth'] ?? '',
      'gender': user['gender'] ?? '',
      'description': user['description'] ?? '',
      'phoneNumber': user['phoneNumber'] ?? '',
    };

    return userMap;
  }

  //update user by id in the database
  static Future<void> updateUserById(
      String userId, Map<String, dynamic> updatedUser) async {
    await FirebaseFirestore.instance
        .collection(Constants.usersCollection)
        .doc(userId)
        .update(updatedUser);
  }

  static Future<List<Map<String, dynamic>>> fetchRoommatesByIdsList(
      List<dynamic> userIds) async {
    final List<Map<String, dynamic>> usersList = [];

    for (final userId in userIds) {
      final user = await FirebaseFirestore.instance
          .collection(Constants.usersCollection)
          .doc(userId)
          .get();

      final userMap = {
        'id': user.id,
        'email': user['email'] ?? '',
        'firstName': user['firstName'] ?? '',
        'lastName': user['lastName'] ?? '',
        'password': user['password'] ?? '',
        'imageUrl': user['imageUrl'] ?? '',
        'dateOfBirth': user['dateOfBirth'] ?? '',
        'gender': user['gender'] ?? '',
        'description': user['description'] ?? '',
        'phoneNumber': user['phoneNumber'] ?? '',
      };
      usersList.add(userMap);
    }

    return usersList;
  }

  // REQUESTS //

  //get all requests from the database
  static Future<List<Map<String, dynamic>>> fetchRequests() async {
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .get();

    if (requests.docs.isEmpty) {
      return [];
    }

    final requestsList = requests.docs.map((request) {
      return {
        'id': request.id,
        'applicantId': request['applicantId'],
        'ownerId': request['ownerId'],
        'apartmentId': request['apartmentId'],
        'sentDate': request['sentDate'],
        'approved': request['approved'],
      };
    }).toList();

    if (requestsList.isEmpty) {
      return [];
    }

    return requestsList;
  }

  //get requests by applicant id from the database
  static Future<List<Map<String, dynamic>>> findRequestsByApplicantId(
      String applicantId) async {
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .get();

    if (requests.docs.isEmpty) {
      return [];
    }

    final requestsList = requests.docs.map((request) {
      return {
        'id': request.id,
        'applicantId': request['applicantId'],
        'ownerId': request['ownerId'],
        'apartmentId': request['apartmentId'],
        'sentDate': request['sentDate'],
        'approved': request['approved'],
      };
    }).toList();

    if (requestsList.isEmpty) {
      return [];
    }

    return requestsList;
  }

  //get requests by owner id from the database
  static Future<List<Map<String, dynamic>>> findRequestsByOwnerId(
      String ownerId) async {
    //get all requests by owner id that have approved either null or true
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    if (requests.docs.isEmpty) {
      return [];
    }

    final requestsList = requests.docs.map((request) {
      return {
        'id': request.id,
        'applicantId': request['applicantId'],
        'ownerId': request['ownerId'],
        'apartmentId': request['apartmentId'],
        'sentDate': request['sentDate'],
        'approved': request['approved'],
      };
    }).toList();

    if (requestsList.isEmpty) {
      return [];
    }

    return requestsList;
  }

  //add request to the database
  static Future<void> addRequest(Request request) async {
    final requestMap = {
      'applicantId': request.applicantId,
      'ownerId': request.ownerId,
      'apartmentId': request.apartmentId,
      'sentDate': Timestamp.now(),
      'approved': null,
    };
    await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .add(requestMap);
  }

  //delete request by applicant id from the database
  static Future<void> deleteRequestByApplicantId(String applicantId) async {
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .get();

    if (requests.docs.isEmpty) {
      return;
    }

    final requestId = requests.docs.first.id;

    await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .doc(requestId)
        .delete();
  }

  //update approved field in request by applicant id and owner id in the database
  static Future<void> updateRequestApprovedField(
      String applicantId, String ownerId, bool approved) async {
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    if (requests.docs.isEmpty) {
      return;
    }

    final requestId = requests.docs.first.id;

    await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .doc(requestId)
        .update({'approved': approved});
  }

  //get request by applicant id and apartment id from the database
  static Future<Request?> findRequestByApplicantIdAndApartmentId(
      String applicantId, String currentApartmentId) async {
    final requests = await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .where('apartmentId', isEqualTo: currentApartmentId)
        .get();

    if (requests.docs.isEmpty) {
      return null;
    }

    final request = requests.docs.first;

    return Request(
      id: request.id,
      applicantId: request['applicantId'],
      ownerId: request['ownerId'],
      apartmentId: request['apartmentId'],
      sentDate: request['sentDate'],
      approved: request['approved'],
    );
  }

  //delete request by applicant id and apartment id from the database
  static Future<void> deleteRequestByApplicantIdAndApartmentId(
      String applicantId, String currentApartmentId) async {
    await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .where('apartmentId', isEqualTo: currentApartmentId)
        .get()
        .then((requests) {
      if (requests.docs.isEmpty) {
        return;
      }

      final requestId = requests.docs.first.id;

      FirebaseFirestore.instance
          .collection(Constants.requestsCollection)
          .doc(requestId)
          .delete();
    });
  }

  static Future<void> deleteAllRequestsToApartment(String apartmentId) async {
    await FirebaseFirestore.instance
        .collection(Constants.requestsCollection)
        .where('apartmentId', isEqualTo: apartmentId)
        .get()
        .then((requests) {
      if (requests.docs.isEmpty) {
        return;
      }

      for (var request in requests.docs) {
        FirebaseFirestore.instance
            .collection(Constants.requestsCollection)
            .doc(request.id)
            .delete();
      }
    });
  }
}
