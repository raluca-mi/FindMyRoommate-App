import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/db_helper.dart';
import '../models/request.dart';

class RequestsProvider with ChangeNotifier {
  List<Request> _sentRequests = [];
  List<Request> _receivedRequests = [];

  List<Request> get sentRequests {
    return [..._sentRequests];
  }

  List<Request> get receivedRequests {
    return [..._receivedRequests];
  }

  //get requests sent by applicant id
  Future<void> fetchSentRequests(String applicantId) async {
    final requestsData = await DBHelper.findRequestsByApplicantId(applicantId);

    _sentRequests = requestsData.map(
      (request) {
        return Request(
          id: request['id'],
          applicantId: request['applicantId'],
          ownerId: request['ownerId'],
          apartmentId: request['apartmentId'],
          sentDate: request['sentDate'],
          approved: request['approved'],
        );
      },
    ).toList();

    notifyListeners();
  }

  //get requests received by owner id
  Future<void> fetchReceivedRequests(String ownerId) async {
    final requestsData = await DBHelper.findRequestsByOwnerId(ownerId);
    //remove requests that have the approve field false, as they should not be displayed
    _receivedRequests =
        requestsData.where((request) => request['approved'] != false).map(
      (request) {
        return Request(
          id: request['id'],
          applicantId: request['applicantId'],
          ownerId: request['ownerId'],
          apartmentId: request['apartmentId'],
          sentDate: request['sentDate'],
          approved: request['approved'],
        );
      },
    ).toList();

    notifyListeners();
  }

  //add request
  Future<void> addRequest(Request request) async {
    await DBHelper.addRequest(request);
    _sentRequests.add(request);
    notifyListeners();
  }

  //undo request by applicant id
  Future<void> undoRequest(
      String applicantId, String currentApartmentId) async {
    await DBHelper.deleteRequestByApplicantIdAndApartmentId(
        applicantId, currentApartmentId);

    _sentRequests
        .removeWhere((request) => request.apartmentId == currentApartmentId);

    notifyListeners();
  }

  //verify request by applicant id and apartment id
  Future<bool> requestExists(String apartmentId) async {
    final request = await DBHelper.findRequestByApplicantIdAndApartmentId(
        FirebaseAuth.instance.currentUser!.uid, apartmentId);
    if (request == null) {
      return false;
    }
    return true;
  }

  //update request on approved field by applicant id and owner id
  Future<void> setRequestApprovedField(
      String applicantId, String ownerId, bool approved) async {
    await DBHelper.updateRequestApprovedField(applicantId, ownerId, approved);

    final existingSentRequestIndex = _sentRequests.indexWhere((request) =>
        request.applicantId == applicantId && request.ownerId == ownerId);
    if (existingSentRequestIndex >= 0) {
      _sentRequests[existingSentRequestIndex].approved = approved;
    }

    final existingReceivedRequestIndex = _receivedRequests.indexWhere(
        (request) =>
            request.applicantId == applicantId && request.ownerId == ownerId);
    if (existingReceivedRequestIndex >= 0) {
      _receivedRequests[existingReceivedRequestIndex].approved = approved;
    }

    if (approved == false && existingReceivedRequestIndex >= 0) {
      _receivedRequests.removeAt(existingReceivedRequestIndex);
    }

    notifyListeners();
  }

  //find request sent for a specific apartment id
  Future<List<Request>> findRequestsByOwnerId(String ownerId) async {
    final requestsData = await DBHelper.findRequestsByOwnerId(ownerId);
    List<Request> apartmentsRequests = [];
    for (var i = 0; i < requestsData.length; i++) {
      final request = Request(
        id: requestsData[i]['id'],
        applicantId: requestsData[i]['applicantId'],
        ownerId: requestsData[i]['ownerId'],
        apartmentId: requestsData[i]['apartmentId'],
        sentDate: requestsData[i]['sentDate'],
        approved: requestsData[i]['approved'],
      );
      apartmentsRequests.add(request);
    }
    return apartmentsRequests;
  }
}
