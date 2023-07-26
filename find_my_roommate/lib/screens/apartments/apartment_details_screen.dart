import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import '../../models/apartment.dart';
import '../../widgets/apartment/apartment_details.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  static const routeName = Constants.apartmentDetailsScreenRoute;

  const ApartmentDetailsScreen({super.key});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final apartment = args['apartment'] as Apartment;
    final requestedMode = args['requestedMode'] as bool;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.apartmentDetailsAppBarText),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ApartmentDetails(apartment.id, requestedMode),
          ],
        ),
      ),
    );
  }
}
