import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/convertor.dart';
import '../../models/user.dart';
import '../../providers/users_provider.dart';
import '../../screens/users/user_details_screen.dart';

class OwnerDetails extends StatelessWidget {
  final String userId;
  const OwnerDetails(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            Provider.of<UsersProvider>(context, listen: false).findById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final owner = snapshot.data as User;

          return InkWell(
            onTap: () => Navigator.of(context)
                .pushNamed(UserDetailsScreen.routeName, arguments: userId),
            child: Card(
              elevation: 0.5,
              color: const Color.fromARGB(255, 237, 236, 241),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(135, 201, 201, 201),
                      radius: 40,
                      backgroundImage: NetworkImage(owner.imageUrl),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${Constants.nameLabel}: ${owner.firstName} ${owner.lastName}',
                              style: const TextStyle(fontSize: 12)),
                          Text(
                              '${Constants.ageLabel}: ${calculateAge(owner.dateOfBirth.toDate())}',
                              style: const TextStyle(fontSize: 12)),
                          Text('${Constants.genderLabel}: ${owner.gender.name}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
