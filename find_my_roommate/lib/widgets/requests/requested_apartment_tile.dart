// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';
import '../../models/apartment.dart';
import '../../providers/apartments_provider.dart';
import '../../providers/requests_provider.dart';
import '../../screens/apartments/apartment_details_screen.dart';

class RequestedApartmentTile extends StatelessWidget {
  final String sectionTile;
  final String currentApartmentId;
  final bool? isApproved;
  const RequestedApartmentTile(
      this.sectionTile, this.currentApartmentId, this.isApproved,
      {super.key});

  Future<void> _declineRequest(
      BuildContext context, Apartment apartment) async {
    try {
      await Provider.of<RequestsProvider>(context, listen: false)
          .setRequestApprovedField(auth.FirebaseAuth.instance.currentUser!.uid,
              apartment.ownerId, false)
          .then((value) {
        _decrementRoommates(context, apartment.id);
        _removeRoommateFromApartment(context, apartment.id);
        DisplayHelper.showSuccessMessage(
            context, 'Request declined definitively!');
      });
    } catch (error) {
      DisplayHelper.showErrorMessage(
          context, 'Error declining request: $error');
    }
  }

  Future<void> _decrementRoommates(
      BuildContext context, String apartmentId) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .decrementCurrentlyOccupiedByField(apartmentId);
  }

  Future<void> _removeRoommateFromApartment(
      BuildContext context, String apartmentId) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .removeRoommateIdFromApartment(
            apartmentId, auth.FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final savedContext = context;

    void undoRequest(BuildContext context) async {
      try {
        await Provider.of<RequestsProvider>(context, listen: false).undoRequest(
            auth.FirebaseAuth.instance.currentUser!.uid, currentApartmentId);
        DisplayHelper.showSuccessMessage(
            context, Constants.requestRemovedSuccessfullyText);
      } catch (error) {
        DisplayHelper.showErrorMessage(context,
            '${Constants.requestRemovedFailedText}: ${error.toString()}');
      }
    }

    return FutureBuilder(
        future: Provider.of<ApartmentsProvider>(context, listen: false)
            .findById(currentApartmentId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.error != null) {
            return Text(
                '${Constants.errorOccuredText}: ${snapshot.error.toString()}');
          } else {
            final apartment = snapshot.data as Apartment;
            return Card(
              color: isApproved == null
                  ? const Color.fromARGB(255, 255, 209, 84)
                  : isApproved == false
                      ? const Color.fromARGB(184, 222, 83, 83)
                      : const Color.fromARGB(255, 67, 136, 65),
              margin: const EdgeInsets.all(10),
              child: Column(children: [
                ListTile(
                  title: Column(
                    children: [
                      if (apartment.isDisabled && sectionTile == 'Pending...')
                        Text(
                          'Apartment has been occupied!',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isApproved == false
                                  ? const Color.fromARGB(255, 184, 182, 182)
                                  : Colors.black),
                        )
                      else if (apartment.isDisabled &&
                          sectionTile == 'Approved')
                        const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Text(
                            'This apartment has been disabled!',
                            style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 255, 243, 6)),
                          ),
                        )
                      else if (apartment.isReserved &&
                          sectionTile == 'Pending...')
                        Text(
                          'Apartment fully reserved!',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isApproved == false
                                  ? const Color.fromARGB(255, 184, 182, 182)
                                  : Colors.black),
                        ),
                      Text(
                        apartment.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isApproved == false
                                ? const Color.fromARGB(255, 184, 182, 182)
                                : Colors.black),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                  subtitle: Text(
                    '${Constants.createdAtText}: ${apartment.createdAt.toDate().day}/${apartment.createdAt.toDate().month}/${apartment.createdAt.toDate().year}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isApproved == false
                            ? const Color.fromARGB(255, 186, 185, 185)
                            : Colors.black54),
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('\$${apartment.price}',
                            style: TextStyle(
                                fontSize: 14,
                                color: isApproved == false
                                    ? const Color.fromARGB(255, 186, 185, 185)
                                    : Colors.black)),
                        if (isApproved == true && !apartment.isDisabled)
                          IconButton(
                              onPressed: () =>
                                  _declineRequest(savedContext, apartment),
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Color.fromARGB(255, 165, 12, 12),
                              )),
                        const SizedBox(
                          height: 10,
                        ),
                        if (isApproved == null)
                          const VerticalDivider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        if (isApproved == null)
                          IconButton(
                            icon: const Icon(
                              Icons.undo_rounded,
                              size: 23,
                              color: Color.fromARGB(204, 0, 0, 0),
                            ),
                            onPressed: () => undoRequest(savedContext),
                          ),
                      ],
                    ),
                  ),
                  focusColor: const Color.fromARGB(255, 189, 191, 254),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        ApartmentDetailsScreen.routeName,
                        arguments: {
                          'apartment': apartment,
                          'requestedMode': true
                        });
                  },
                ),
              ]),
            );
          }
        });
  }
}
