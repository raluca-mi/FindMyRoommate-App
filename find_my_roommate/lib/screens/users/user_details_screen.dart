import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import '../../widgets/user/owner_details.dart';

class UserDetailsScreen extends StatefulWidget {
  static const routeName = Constants.userDetailsScreenRoute;
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final ownerId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          OwnerDetails(ownerId),
        ]),
      ),
    );
  }
}
