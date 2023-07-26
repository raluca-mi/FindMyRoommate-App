import 'package:find_my_roommate/helpers/display_helper.dart';
import 'package:find_my_roommate/models/apartment.dart';
import 'package:find_my_roommate/providers/users_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/enums/apartment_status_enum.dart';
import '../../models/request.dart';
import '../../providers/apartments_provider.dart';
import '../../providers/requests_provider.dart';
import '../../models/user.dart';
import '../../screens/users/user_details_screen.dart';

class RequestingUserTile extends StatelessWidget {
  final Request? receivedRequest;
  const RequestingUserTile(this.receivedRequest, {super.key});

  Future<void> _answerRequest(
      BuildContext context, String userId, bool isApproved) async {
    try {
      await Provider.of<RequestsProvider>(context, listen: false)
          .setRequestApprovedField(
              userId, auth.FirebaseAuth.instance.currentUser!.uid, isApproved)
          .then((value) {
        if (isApproved == false) {
          DisplayHelper.showSuccessMessage(context, 'Request rejected!');
        } else {
          _incrementRoommates(context);
          _addRoommateToApartment(context, userId);
          DisplayHelper.showSuccessMessage(context, 'Request approved!');
        }
      });
    } catch (error) {
      DisplayHelper.showErrorMessage(context, Constants.errorOccuredText);
    }
  }

  Future<void> _declineRequestAfterApproval(
      BuildContext context, String applicantId, String apartmentId) async {
    try {
      await Provider.of<RequestsProvider>(context, listen: false)
          .setRequestApprovedField(
              applicantId, auth.FirebaseAuth.instance.currentUser!.uid, false)
          .then((value) {
        _decrementRoommates(context);
        _removeRoommateFromApartment(context, applicantId, apartmentId);
        DisplayHelper.showSuccessMessage(
            context, 'Request declined definitively!');
      });
    } catch (error) {
      DisplayHelper.showErrorMessage(context, Constants.errorOccuredText);
    }
  }

  Future<void> _decrementRoommates(BuildContext context) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .decrementCurrentlyOccupiedByField(receivedRequest!.apartmentId);
  }

  Future<void> _removeRoommateFromApartment(
      BuildContext context, String userId, String apartmentId) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .removeRoommateIdFromApartment(apartmentId, userId);
  }

  Future<void> _incrementRoommates(BuildContext context) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .incrementCurrentlyOccupiedByField(receivedRequest!.apartmentId);
  }

  Future<void> _addRoommateToApartment(
      BuildContext context, String userId) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .addRoommateIdToApartment(receivedRequest!.apartmentId, userId);
  }

  @override
  Widget build(BuildContext context) {
    final savedContext = context;
    final applicantId = receivedRequest!.applicantId;

    return FutureBuilder(
      future: Provider.of<UsersProvider>(context, listen: false)
          .findById(applicantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.error != null) {
          return Text(
              '${Constants.errorOccuredText}: ${snapshot.error.toString()}');
        } else {
          final user = snapshot.data as User;
          return FutureBuilder(
            future: Provider.of<ApartmentsProvider>(context, listen: false)
                .findById(receivedRequest!.apartmentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.error != null) {
                return Text(
                    '${Constants.errorOccuredText}: ${snapshot.error.toString()}');
              } else {
                final apartment = snapshot.data as Apartment;
                final apartmentStatus = getApartmentStatus(apartment);

                return Card(
                    color: receivedRequest!.approved == null
                        ? Colors.white
                        : receivedRequest!.approved == false
                            ? const Color.fromARGB(184, 158, 156, 156)
                            : const Color.fromARGB(255, 67, 136, 65),
                    margin: const EdgeInsets.all(10),
                    child: Column(children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 20,
                          backgroundImage: NetworkImage(user.imageUrl),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        trailing: apartmentStatus == ApartmentStatus.disabled
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.amber,
                                ),
                                child: const Text(
                                  Constants.apartmentDisabledText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : apartmentStatus == ApartmentStatus.reserved &&
                                    receivedRequest!.approved == null
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromARGB(
                                          255, 158, 167, 233),
                                    ),
                                    child: const Text(
                                      Constants.apartmentReservedText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : receivedRequest!.approved == null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async =>
                                                await _answerRequest(
                                                    savedContext,
                                                    user.id,
                                                    true),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Color.fromARGB(
                                                  255, 104, 117, 230),
                                            ),
                                            onPressed: () async =>
                                                await _answerRequest(
                                                    savedContext,
                                                    user.id,
                                                    false),
                                          ),
                                        ],
                                      )
                                    : receivedRequest!.approved == true
                                        ? IconButton(
                                            onPressed: () =>
                                                _declineRequestAfterApproval(
                                                    savedContext,
                                                    user.id,
                                                    receivedRequest!
                                                        .apartmentId),
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Color.fromARGB(
                                                  255, 165, 12, 12),
                                            ))
                                        : const SizedBox(),
                        tileColor: const Color.fromARGB(132, 235, 234, 255),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              UserDetailsScreen.routeName,
                              arguments: user.id);
                        },
                      ),
                    ]));
              }
            },
          );
        }
      },
    );
  }
}
