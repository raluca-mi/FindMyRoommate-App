import 'package:find_my_roommate/screens/apartments/add_apartment_container_screen.dart';
import 'package:find_my_roommate/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import '../providers/apartments_provider.dart';
import '../providers/users_provider.dart';
import '../providers/requests_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/apartments/apartment_details_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/requests/requests_received_screen.dart';
import '../screens/requests/requests_sent_screen.dart';
import '../screens/users/user_details_screen.dart';
import '../screens/users/edit_user_screen.dart';
import 'screens/apartments/my_apartment_container_screen.dart';
import './helpers/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ApartmentsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RequestsProvider(),
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Constants.appTitle,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color.fromARGB(255, 139, 139, 234),
            fontFamily: Constants.ralewayFont,
            backgroundColor: const Color.fromARGB(223, 219, 221, 222),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(255, 79, 98, 173),
              secondary: const Color.fromARGB(255, 55, 49, 96),
            ),
            textTheme: TextTheme(
              bodyText1: const TextStyle(
                color: Color.fromRGBO(255, 251, 251, 1),
                fontSize: 16,
              ),
              bodyText2: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              headline1: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              headline2: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
              headline3: const TextStyle(
                color: Color.fromARGB(255, 11, 140, 238),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              headline4: TextStyle(
                color: Colors.grey[800],
                fontSize: 20,
              ),
            ),
          ),
          home: const AuthScreen(),
          routes: {
            HomeScreen.routeName: (ctx) => const HomeScreen(),
            ForgotPasswordScreen.routeName: (ctx) =>
                const ForgotPasswordScreen(),
            ApartmentDetailsScreen.routeName: (ctx) =>
                const ApartmentDetailsScreen(),
            EditUserScreen.routeName: (ctx) => const EditUserScreen(),
            MyApartmentContainerScreen.routeName: (ctx) =>
                const MyApartmentContainerScreen(),
            AddApartmentContainerScreen.routeName: (ctx) =>
                const AddApartmentContainerScreen(),
            UserDetailsScreen.routeName: (ctx) => const UserDetailsScreen(),
            RequestsSentScreen.routeName: (ctx) => const RequestsSentScreen(),
            RequestsReceivedScreen.routeName: (ctx) =>
                const RequestsReceivedScreen(),
            StatisticsScreen.routeName: (ctx) => const StatisticsScreen(),
          }),
    );
  }
}
