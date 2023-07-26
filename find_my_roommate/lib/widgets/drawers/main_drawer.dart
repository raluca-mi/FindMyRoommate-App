import 'package:find_my_roommate/helpers/constants.dart';
import 'package:find_my_roommate/screens/apartments/my_apartment_container_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/requests/requests_sent_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/users/edit_user_screen.dart';
import '../../screens/requests/requests_received_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 235, 237, 252),
      child: Column(children: [
        AppBar(
            title: const Text(
              Constants.settingsAppBarText,
            ),
            automaticallyImplyLeading: false),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(Constants.profileDrawerItemText,
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).pushNamed(EditUserScreen.routeName);
            }),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text(Constants.myApartmentDrawerItemText,
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(MyApartmentContainerScreen.routeName);
            }),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.send_rounded),
            title: const Text(Constants.requestsSentDrawerItemText,
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).pushNamed(RequestsSentScreen.routeName);
            }),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.inbox_rounded),
            title: const Text(Constants.requestsReceivedDrawerItemText,
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).pushNamed(RequestsReceivedScreen.routeName);
            }),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text(Constants.statisticsDrawerItemText,
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).pushNamed(StatisticsScreen.routeName);
            }),
        const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.26,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app_rounded),
          title: const Text(Constants.logoutDrawerItemText,
              style: TextStyle(color: Colors.black)),
          onTap: () {
            signUserOut();
          },
        ),
      ]),
    );
  }
}
