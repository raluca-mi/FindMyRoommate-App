import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_my_roommate/helpers/enums/apartment_status_enum.dart';
import 'package:find_my_roommate/providers/requests_provider.dart';
import 'package:find_my_roommate/widgets/apartment/page_view_gallery.dart';
import 'package:find_my_roommate/widgets/customized/warning_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../models/request.dart';
import '../../screens/location/map_screen.dart';
import '../customized/custom_button.dart';
import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';
import '../../models/apartment.dart';
import '../../providers/apartments_provider.dart';
import '../charts/requests_chart.dart';
import '../user/owner_details_card.dart';
import '../user/roommates_profiles.dart';

class ApartmentDetails extends StatelessWidget {
  final String currentApartmentId;
  final bool requestedMode;

  const ApartmentDetails(this.currentApartmentId, this.requestedMode,
      {super.key});

  void _sendRequest(BuildContext context, String ownerId) async {
    final isAlreadyRequested =
        await Provider.of<RequestsProvider>(context, listen: false)
            .requestExists(currentApartmentId);

    if (isAlreadyRequested == false) {
      try {
        final request = Request(
          id: '',
          applicantId: auth.FirebaseAuth.instance.currentUser!.uid,
          ownerId: ownerId,
          apartmentId: currentApartmentId,
          sentDate: Timestamp.now(),
          approved: null,
        );

        // ignore: use_build_context_synchronously
        await Provider.of<RequestsProvider>(context, listen: false)
            .addRequest(request);

        // ignore: use_build_context_synchronously
        DisplayHelper.showSuccessMessage(
            context, Constants.apartmentRequestedSuccessfullyText);
      } catch (error) {
        // ignore: use_build_context_synchronously
        DisplayHelper.showErrorMessage(context,
            '${Constants.apartmentRequestedFailedText}: ${error.toString()}');
      }
    } else {
      // ignore: use_build_context_synchronously
      DisplayHelper.showErrorMessage(
          context, Constants.apartmentAlreadyRequestedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedContext = context;

    return FutureBuilder(
        future: Provider.of<ApartmentsProvider>(context, listen: false)
            .findById(currentApartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          final loadedApartment = snapshot.data as Apartment;
          final apartmentStatus = getApartmentStatus(loadedApartment);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageViewGallery(imageUrls: loadedApartment.imageUrl),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loadedApartment.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text('${Constants.ownerDetailsAppBarText}: ',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 41, 59, 84))),
                      OwnerDetails(loadedApartment.ownerId.trim()),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on_sharp),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              loadedApartment.address,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 41, 59, 84),
                              ),
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (ctx) => MapScreen(
                                    initialLocation: GeoPoint(
                                        loadedApartment.coordinates.latitude,
                                        loadedApartment.coordinates.longitude),
                                    isSelecting: false,
                                    apartmentTitle: loadedApartment.title,
                                  )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 0.5,
                              color: const Color.fromARGB(255, 216, 215, 215),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: const Color.fromARGB(255, 239, 239, 239),
                              height: 170,
                              width: double.infinity,
                              alignment: Alignment.center,
                              // ignore: unnecessary_null_comparison
                              child: loadedApartment.previewLocationImageUrl ==
                                      null
                                  ? const Text(
                                      'No Location Chosen',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    )
                                  : FractionallySizedBox(
                                      widthFactor: 1.0,
                                      child: AspectRatio(
                                        aspectRatio: 16 /
                                            9, // Adjust the aspect ratio as needed
                                        child: Image.network(
                                          loadedApartment
                                              .previewLocationImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Price: ${loadedApartment.price} \u20ac',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 41, 59, 84)),
                      ),

                      const SizedBox(height: 10),
                      if (apartmentStatus == ApartmentStatus.reserved)
                        const WarningCard(
                            Constants.apartmentReservedAtTheMomentText),

                      const SizedBox(height: 20),
                      const Text(
                        '${Constants.descriptionLabel}:',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 41, 59, 84)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loadedApartment.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '${Constants.facilitiesLabel}:',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 41, 59, 84)),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var facility in loadedApartment.facilities)
                            Row(
                              children: [
                                const Icon(Icons.arrow_right),
                                const SizedBox(width: 10),
                                Text(
                                  facility,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                        ],
                      ),
                      //capacity occupied
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.people),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${loadedApartment.currentlyOccupiedBy}/${loadedApartment.totalCapacity}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 41, 59, 84)),
                            ),
                          ),
                        ],
                      ),

                      //applicants accepted

                      const SizedBox(height: 10),

                      RoommatesProfiles(loadedApartment.roommatesIds),
                      const SizedBox(height: 10),

                      RequestChart(loadedApartment.ownerId.trim()),

                      const SizedBox(height: 20),
                      if (requestedMode == false)
                        CustomButton(
                          onTap: () => _sendRequest(
                              savedContext, loadedApartment.ownerId.trim()),
                          text: apartmentStatus == ApartmentStatus.available
                              ? Constants.applyButtonText
                              : Constants.applyForWaitingListButtonText,
                        ),

                      const SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${Constants.createdAtText}: ${loadedApartment.createdAt.toDate().day}/${loadedApartment.createdAt.toDate().month}/${loadedApartment.createdAt.toDate().year}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${Constants.lastModifiedText}: ${loadedApartment.lastModifiedAt.toDate().day}/${loadedApartment.lastModifiedAt.toDate().month}/${loadedApartment.lastModifiedAt.toDate().year}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
