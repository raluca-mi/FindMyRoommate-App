import 'package:find_my_roommate/screens/apartments/add_apartment_container_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../models/apartment.dart';
import '../../providers/apartments_provider.dart';
import 'my_apartment_screen.dart';

class MyApartmentContainerScreen extends StatefulWidget {
  static const routeName = Constants.myApartmentScreenRoute;
  const MyApartmentContainerScreen({super.key});

  @override
  State<MyApartmentContainerScreen> createState() =>
      _MyApartmentContainerScreenState();
}

class _MyApartmentContainerScreenState
    extends State<MyApartmentContainerScreen> {
  Apartment? _apartment;
  bool? _isDisabledStatus;

  void _toggleDisabledStatus() async {
    setState(() {
      _isDisabledStatus = !_isDisabledStatus!;
    });
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .updateIsDisabledField(_apartment!.id, _isDisabledStatus!);
  }

  void _refreshApartment() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: Provider.of<ApartmentsProvider>(context)
            .findByOwnerId(auth.FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text(Constants.myApartmentAppBarText),
                ),
                body: const Center(child: CircularProgressIndicator()));
          } else if (snapshot.error != null) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text(Constants.myApartmentAppBarText),
                ),
                body: Center(
                    child: Text(
                        'Error loading the apartment: ${snapshot.error.toString()}')));
          } else if (snapshot.data == null) {
            _apartment = null;
            _isDisabledStatus = null;
            return Padding(
              padding: const EdgeInsets.all(0),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(Constants.myApartmentAppBarText),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(Constants.youHaveNotAddedApartmentText),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AddApartmentContainerScreen.routeName);
                  },
                  tooltip: Constants.addApartmentButtonText,
                  child: const Icon(Icons.add),
                ),
              ),
            );
          } else {
            _apartment = snapshot.data as Apartment;
            _isDisabledStatus = _apartment!.isDisabled;

            return MyApartmentScreen(
              oldApartment: _apartment,
              toggleDisabledStatus: _toggleDisabledStatus,
              refreshApartment: _refreshApartment,
            );
          }
        });
  }
}
