import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../providers/users_provider.dart';
import '../../screens/users/user_details_screen.dart';

class RoommatesProfiles extends StatelessWidget {
  final List<dynamic>? roommatesIds;
  const RoommatesProfiles(this.roommatesIds, {super.key});

  @override
  Widget build(BuildContext context) {
    if (roommatesIds == null || roommatesIds!.isEmpty) {
      return const Text(Constants.noRoommatesYetText);
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: Provider.of<UsersProvider>(context, listen: false)
              .fetchRoommatesByIds(roommatesIds!),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              return Text(
                  'Error loading the roommates: ${snapshot.error.toString()}');
            } else {
              return Consumer<UsersProvider>(
                builder: (ctx, usersData, _) {
                  final roommates = usersData.roommates;
                  if (roommates.isEmpty) {
                    return const Center(
                        child: Text(Constants.noRoommatesYetText));
                  }
                  return Column(
                    children: roommates
                        .map((roommate) => ChangeNotifierProvider.value(
                              value: roommate,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      UserDetailsScreen.routeName,
                                      arguments: roommate.id);
                                },
                                child: Text(
                                    '${roommate.firstName} ${roommate.lastName}'),
                              ),
                            ))
                        .toList(),
                  );
                },
              );
            }
          },
        ),
      );
    }
  }
}
